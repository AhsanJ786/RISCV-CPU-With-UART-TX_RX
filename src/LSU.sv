module lsu (op,alu_out,uart_sel,dmm_sel
);
input logic [6:0] op;
input logic [31:0] alu_out;
output logic uart_sel;
output logic dmm_sel;


assign dmm_sel  = (op == 7'b0000011 | op == 7'b0100011) && (alu_out[31:28]== 4'h0);
assign uart_sel = (op == 7'b0000011 | op == 7'b0100011) && (alu_out[31:28]== 4'h8);

    
endmodule