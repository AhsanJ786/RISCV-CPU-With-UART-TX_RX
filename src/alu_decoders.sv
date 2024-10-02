module alu_decoders(AluOp,funct3,funct7,op,ALU_control);

    input [1:0]AluOp;
    input [2:0]funct3;
    input [6:0]funct7,op;
    output [2:0]ALU_control;

   
    assign ALU_control = (AluOp == 2'b00) ? 3'b000 :
                         ((AluOp == 2'b01) & ((funct3 == 3'b000)|(funct3 == 3'b100) |(funct3 == 3'b101))) ? 3'b001 :
                         ((AluOp == 2'b10) & (funct3 == 3'b000) & ({op[5],funct7[5]} == 2'b11)) ? 3'b001 : 
                         ((AluOp == 2'b10) & (funct3 == 3'b000) & ({op[5],funct7[5]} != 2'b11)) ? 3'b000 : 
                         ((AluOp == 2'b10) & (funct3 == 3'b010)) ? 3'b101 : 
                         ((AluOp == 2'b10) & (funct3 == 3'b110)) ? 3'b011 : 
                         ((AluOp == 2'b10) & (funct3 == 3'b111)) ? 3'b010 :
                         ((AluOp == 2'b10) & (funct3 == 3'b100)) ? 3'b100 :
                         ((AluOp == 2'b10) & (funct3 == 3'b001)) ? 3'b110 :
                         ((AluOp == 2'b10) & (funct3 == 3'b001) & funct7[5] == 1'b0) ? 3'b111 :    
                                                                   3'b000 ;

endmodule