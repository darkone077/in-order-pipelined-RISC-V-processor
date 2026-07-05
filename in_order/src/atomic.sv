module atomic #(
    parameter aswap=4'b0001,
    parameter aadd=4'b0000,
    parameter axor=4'b0010,
    parameter aand=4'b0011,
    parameter aor=4'b0100,
    parameter amin=4'b0101,
    parameter amax=4'b0110,
    parameter aminu=4'b0111,
    parameter amaxu=4'b1000
) (
    input logic [3:0] a_ctrl,
    input logic [31:0] reg_data,
    input logic [31:0] read_data,
    output logic [31:0] wrtm_data
);

    always_comb begin 
        case (a_ctrl)
            aswap:begin 
                wrtm_data=reg_data;
            end

            aadd:begin
                wrtm_data=reg_data+read_data;
            end
            axor:begin 
                wrtm_data=read_data^reg_data;
            end
            aand:begin 
                wrtm_data=read_data&reg_data;
            end
            aor:begin 
                wrtm_data=read_data|reg_data;
            end
            amin:begin 
                wrtm_data=($signed(read_data)>$signed(reg_data))?reg_data:read_data;
            end
            amax:begin
                 wrtm_data=($signed(read_data)>$signed(reg_data))?read_data:reg_data;
             end
             amaxu:begin 
                 wrtm_data=(read_data>reg_data)?read_data:reg_data;
             end
             aminu:begin
                 wrtm_data=(read_data>reg_data)?reg_data:read_data;
              end
            default:begin
                wrtm_data=32'b0;
            end
        endcase
    end
    
endmodule