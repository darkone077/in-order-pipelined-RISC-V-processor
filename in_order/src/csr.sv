module csr#(
    parameter IVT_BASE=30'h400000,//this is actual BASE>>2
    parameter INST_ADDR_MISALIGN=31'd0,
    parameter ILLEGAL_INST=31'd2,
    parameter BREAKPOINT=31'd3,
    parameter LOAD_ADDR_MISALIGNED=31'd4,
    parameter STR_ADDR_MISALIGNED=31'd6,
    parameter M_ECALL=31'd11,
    parameter M_SW_INT=31'd3,
    parameter M_TIMER_INT=31'd7,
    parameter EXTERNAL_INT=31'd11 

)(
    input logic clk,
    input logic rst_n,
    //[11:10]:00-10=read/wrt,11=read,[9:8]:00=unpriv/user,01=supervisor,10=hypervisor,11=machine
    input logic [11:0] csr_addr,
    input logic csr_wrt_en,
    input logic [31:0] csr_wrt,
    output logic [31:0] csr_read,

    //mclint
    input logic mclint_timer_int,//mtip
    input logic mclint_sw_int,//msip

    //traps
    input logic inst_addr_misaligned,
    input logic illegal_inst,
    input logic breakpoint,
    input logic load_addr_misaligned,
    input logic str_addr_misaligned,
    input logic m_ecall,

    input logic [31:0] pcf,
    input logic [31:0] pcd,
    input logic [31:0] pce,
    output logic [31:0] exception_pc,

    input logic busy,div_busy,regmeme,regmemd,
    
    //external interrupts
    input logic [15:0] irq,
    input logic external_irq,//meip
    
    output logic trap,

    input logic mret
);
    struct packed {
        logic [31:0] mstatus;
        logic [31:0] mstatush;
        logic [31:0] misa;
        logic [31:0] marchid;
        logic [31:0] mhartid;
        logic [31:0] mtvec;
        logic [31:0] mimpid;
        logic [31:0] mie;
        logic [31:0] mip;
        logic [31:0] mscratch;
        logic [31:0] mepc;
        logic [31:0] mcause;
        logic [31:0] mtval;
        logic [31:0] mconfigptr;
        logic [63:0] menvcfg;
    } csr_m;

    logic sync_exception;
    logic ex_exception;
    logic de_exception;
    logic [31:0] current_pc;

    struct packed{
        //logic [15:0] irq_buffer;
        logic external_irq_buffer;
        logic mclint_timer_int_buffer;
        logic mclint_sw_int_buffer;
    } int_buffer;

    always_ff @(posedge clk) begin
        if (~rst_n) begin
            //machine mode specifc CSRs
            csr_m.misa<={2'b01,4'b0000,26'h0001101};//[31:30]: MXLEN=32,[25:0]: Extensions Z to A
            csr_m.marchid<=32'b0;
            csr_m.mimpid<=32'b0;
            csr_m.mhartid<=32'b0;
            csr_m.mstatus<={1'b0,6'b0,12'b0,2'b11,6'b0,1'b0,1'b0,1'b0,1'b0,1'b0};
            csr_m.mstatush<={21'b0,2'b00,1'b0,4'b0,4'b0};
            csr_m.mtvec<={IVT_BASE,2'b00};//[31:2]: BASE>>2,[1:0]: 00=direct, 01=vectorised
            csr_m.mie<={16'b0,2'b00,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0};
            csr_m.mscratch<=32'b0;
            csr_m.mepc<=32'b0;
            csr_m.mcause<={1'b0,31'b0};
            csr_m.mtval<=32'b0;
            csr_m.mconfigptr<=32'b0;
            csr_m.menvcfg<={5'b0,25'b0,2'b00,24'b0,6'b0,1'b0,1'b0};

            //irq buffers
            //int_buffer.irq_buffer<=16'b0;
            int_buffer.external_irq_buffer<=1'b0;
            int_buffer.mclint_timer_int_buffer<=1'b0;
            int_buffer.mclint_sw_int_buffer<=1'b0;
        end
        else begin
            if (busy) begin
                if (~int_buffer.external_irq_buffer&external_irq) begin
                    int_buffer.external_irq_buffer<=1'b1;
                end
                if (~int_buffer.mclint_sw_int_buffer&mclint_sw_int) begin
                    int_buffer.mclint_sw_int_buffer<=1'b1;
                end
                if (~int_buffer.mclint_timer_int_buffer&mclint_timer_int) begin
                    int_buffer.mclint_timer_int_buffer<=1'b1;
                end
            end
            else begin
                 /* verilator lint_off WIDTHTRUNC */
                if (int_buffer.external_irq_buffer&csr_m.mip[EXTERNAL_INT]&csr_m.mie[EXTERNAL_INT]) begin
                    int_buffer.external_irq_buffer<=1'b0;
                end
                if (int_buffer.mclint_sw_int_buffer&mclint_sw_int&csr_m.mip[M_SW_INT]&csr_m.mie[M_SW_INT]) begin
                    int_buffer.mclint_sw_int_buffer<=1'b0;
                end
                if (int_buffer.mclint_timer_int_buffer&mclint_timer_int&csr_m.mip[M_TIMER_INT]&csr_m.mie[M_TIMER_INT]) begin
                    int_buffer.mclint_timer_int_buffer<=1'b0;
                end
                 /* verilator lint_on WIDTHTRUNC */
            end
            if(csr_m.mip!=32'b0&csr_m.mstatus[3]&~busy)begin
                /* verilator lint_off WIDTHTRUNC */
                if (csr_m.mip[EXTERNAL_INT]&csr_m.mie[EXTERNAL_INT]) begin
                    csr_m.mepc<=current_pc;
                    csr_m.mcause<={1'b1,EXTERNAL_INT};
                    csr_m.mstatus[7]<=csr_m.mstatus[3];
                    csr_m.mstatus[3]<=1'b0;
                end
                else if (csr_m.mip[M_SW_INT]&csr_m.mie[M_SW_INT]) begin
                    csr_m.mepc<=current_pc;
                    csr_m.mcause<={1'b1,M_SW_INT};
                    csr_m.mstatus[7]<=csr_m.mstatus[3];
                    csr_m.mstatus[3]<=1'b0;
                end
                else if (csr_m.mip[M_TIMER_INT]&csr_m.mie[M_TIMER_INT]) begin
                    csr_m.mepc<=current_pc;
                    csr_m.mcause<={1'b1,M_TIMER_INT};
                    csr_m.mstatus[7]<=csr_m.mstatus[3];
                    csr_m.mstatus[3]<=1'b0;
                end
                /* verilator lint_on WIDTHTRUNC */
            end
            else if (breakpoint&~(busy|div_busy)) begin
                csr_m.mepc<=current_pc;
                csr_m.mcause<={1'b0,BREAKPOINT};
                csr_m.mstatus[7]<=csr_m.mstatus[3];
                csr_m.mstatus[3]<=1'b0;
            end
            else if (illegal_inst&~(busy|div_busy)) begin
                csr_m.mepc<=current_pc;
                csr_m.mcause<={1'b0,ILLEGAL_INST};
                csr_m.mstatus[7]<=csr_m.mstatus[3];
                csr_m.mstatus[3]<=1'b0; 
            end
            else if (inst_addr_misaligned&~(busy|div_busy)) begin
                csr_m.mepc<=current_pc;
                csr_m.mcause<={1'b0,INST_ADDR_MISALIGN};
                csr_m.mstatus[7]<=csr_m.mstatus[3];
                csr_m.mstatus[3]<=1'b0;
            end
            else if (m_ecall&~(busy|div_busy)) begin
                csr_m.mepc<=current_pc;
                csr_m.mcause<={1'b0,M_ECALL};
                csr_m.mstatus[7]<=csr_m.mstatus[3];
                csr_m.mstatus[3]<=1'b0;
            end
            else if (load_addr_misaligned&~(busy|div_busy)) begin
                csr_m.mepc<=current_pc;
                csr_m.mcause<={1'b0,LOAD_ADDR_MISALIGNED};
                csr_m.mstatus[7]<=csr_m.mstatus[3];
                csr_m.mstatus[3]<=1'b0;
            end
            else if (str_addr_misaligned&~(busy|div_busy)) begin
                csr_m.mepc<=current_pc;
                csr_m.mcause<={1'b0,STR_ADDR_MISALIGNED};
                csr_m.mstatus[7]<=csr_m.mstatus[3];
                csr_m.mstatus[3]<=1'b0;
            end
            else if (mret&~(busy|div_busy)) begin
                csr_m.mstatus[3]<=csr_m.mstatus[7];
                csr_m.mstatus[7]<=1'b1;
            end
            else if(csr_wrt_en&~busy)begin
                case (csr_addr)
                //machine mode CSRs
                    12'h300:
                        csr_m.mstatus<={csr_wrt[31],6'b0,csr_wrt[24:5],1'b0,csr_wrt[3],1'b0,csr_wrt[1],1'b0};
                    12'h310:
                        csr_m.mstatush<={21'b0,csr_wrt[10:9],1'b0,csr_wrt[7:4],4'b0};
                    12'h304:
                        csr_m.mie<={csr_wrt[31:16],2'b00,csr_wrt[13],1'b0,csr_wrt[11],1'b0,1'b0,1'b0,csr_wrt[7],1'b0,1'b0,1'b0,csr_wrt[3],1'b0,1'b0,1'b0};
                    12'h305:
                        csr_m.mtvec<={csr_wrt[31:2],1'b0,csr_wrt[0]};
                    12'h340:
                        csr_m.mscratch<=csr_wrt;
                    12'h341:
                        csr_m.mepc<={csr_wrt[31:2],2'b00};
                    12'h342:begin
                        if (csr_wrt[31]) begin
                            if (((csr_wrt[30:0]<16)&csr_wrt[0])|csr_wrt[30:0]>=16) begin
                                csr_m.mcause<=csr_wrt;
                            end
                        end
                        else begin
                            if(~(csr_wrt[30:0]==10|csr_wrt[30:0]==14|csr_wrt[30:0]==17|(csr_wrt[30:0]>=20&csr_wrt[30:0]<=23)|(csr_wrt[30:0]>=32&csr_wrt[30:0]<=47)|csr_wrt[30:0]>=64))begin
                                csr_m.mcause<=csr_wrt;
                            end
                        end
                    end
                    12'h30a:
                        csr_m.menvcfg[31:0]<={24'b0,csr_wrt[7:2],1'b0,csr_wrt[0]};
                    12'h31a:
                        csr_m.menvcfg[63:32]<={csr_wrt[31:27],25'b0,csr_wrt[1:0]};
                    default:
                        ;
                endcase
            end
        end
    end   

    always_comb begin
        exception_pc=32'b0;
        sync_exception=breakpoint|illegal_inst|inst_addr_misaligned|m_ecall|load_addr_misaligned|str_addr_misaligned;

        csr_m.mip={irq,2'b00,1'b0,1'b0,external_irq|int_buffer.external_irq_buffer,1'b0,1'b0,1'b0,mclint_timer_int|int_buffer.mclint_timer_int_buffer,1'b0,1'b0,1'b0,mclint_sw_int|int_buffer.mclint_sw_int_buffer,1'b0,1'b0,1'b0};

        de_exception=1'b0;
        ex_exception=inst_addr_misaligned|load_addr_misaligned|str_addr_misaligned|illegal_inst|breakpoint|m_ecall|mret;

        if (ex_exception|((csr_m.mip!=32'b0&csr_m.mstatus[3])&regmeme)) begin
            current_pc=pce;
        end
        else if (de_exception|((csr_m.mip!=32'b0&csr_m.mstatus[3])&regmemd)) begin
            current_pc=pcd;
        end
        else begin
            current_pc=pcf;
        end

        if (~busy&(csr_m.mip!=32'b0&csr_m.mstatus[3])|(mret|sync_exception)&~(busy|div_busy)) begin
            trap=1;
        end
        else begin
            trap=0;
        end

        if(csr_m.mip!=32'b0&csr_m.mstatus[3]&~busy)begin
            /* verilator lint_off WIDTHTRUNC */
            if (csr_m.mip[EXTERNAL_INT]&csr_m.mie[EXTERNAL_INT]) begin
                if (csr_m.mtvec[0]) begin
                    exception_pc={csr_m.mtvec[31:2],2'b00}+4*EXTERNAL_INT;
                end
                else begin
                exception_pc={csr_m.mtvec[31:2],2'b00}; 
                end
            end
            else if (csr_m.mip[M_SW_INT]&csr_m.mie[M_SW_INT]) begin
                if (csr_m.mtvec[0]) begin
                    exception_pc={csr_m.mtvec[31:2],2'b00}+4*M_SW_INT;
                end
                else begin
                exception_pc={csr_m.mtvec[31:2],2'b00}; 
                end
            end
            else if (csr_m.mip[M_TIMER_INT]&csr_m.mie[M_TIMER_INT]) begin
                if (csr_m.mtvec[0]) begin
                    exception_pc={csr_m.mtvec[31:2],2'b00}+4*M_TIMER_INT;
                end
                else begin
                exception_pc={csr_m.mtvec[31:2],2'b00}; 
                end
            end
            /* verilator lint_on WIDTHTRUNC */
        end
        else if (sync_exception&~(busy|div_busy)) begin
            exception_pc={csr_m.mtvec[31:2],2'b00}; 
        end
        else if (mret&~busy) begin
            exception_pc=csr_m.mepc;
        end
        
        case (csr_addr)
        //machine mode CSRs
            12'h300:
                csr_read=csr_m.mstatus;
            12'h310:
                csr_read=csr_m.mstatush;
            12'h304:
                csr_read=csr_m.mie;
            12'h344:
                csr_read=csr_m.mip;
            12'h305:
                csr_read=csr_m.mtvec;
            12'h340:
                csr_read=csr_m.mscratch;
            12'h341:
                csr_read=csr_m.mepc;
            12'h342:
                csr_read=csr_m.mcause;
            12'h30a:
                csr_read=csr_m.menvcfg[31:0];
            12'h31a:
                csr_read=csr_m.menvcfg[63:32];
            12'hf12:
                csr_read=csr_m.marchid;
            12'hf13:
                csr_read=csr_m.mimpid;
            12'hf14:
                csr_read=csr_m.mhartid;
            12'hf15:
                csr_read=csr_m.mconfigptr;
            default:
                csr_read=32'b0;
        endcase
    end
endmodule