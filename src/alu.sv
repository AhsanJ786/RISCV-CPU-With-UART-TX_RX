module alu(ALU_A,ALU_B,ALU_control,ALU_output,z,n,v,c);
  // inputs
  input [31:0] ALU_A,ALU_B;
  input [2:0] ALU_control;
  //output
  output  [31:0]ALU_output;
  output  z,n,v,c;
  // internal wires
  wire [31:0]A_and_B;
  wire [31:0]A_or_B;
  wire [31:0]not_B;
  wire [31:0]mux_1;
  wire [31:0]sum;
  wire [31:0]mux_2;
  wire cout;
  wire [31:0]slt;
  wire [31:0] A_xor_B;
  wire [31:0] A_sll_B;
  wire [31:0] A_srl_B;
  wire j;

  // AND of ALU
  assign A_and_B = ALU_A & ALU_B;
  // OR of ALU
  assign A_or_B  = ALU_A | ALU_B;
  // xor of Alu 
  assign A_xor_B = ALU_A ^ ALU_B;
  // sll A and B
  assign A_sll_B = ALU_A << ALU_B;
   // srl A and B
  assign A_srl_B = ALU_A >> ALU_B;
  // not on B for subtraction bt 2 complement
  assign not_B   = ~ALU_B;
  // mux for choosing subtraction 
  assign mux_1 = (ALU_control[0] == 1'b0) ? ALU_B : not_B ; 
  // addition and subtracrion
  assign {cout,sum }  = ALU_A + mux_1 + ALU_control[0];
  // mux for choosing everything
  assign mux_2 = (ALU_control[2:0] == 3'b000) ? sum:
                 (ALU_control[2:0] == 3'b001) ? sum:
                 (ALU_control[2:0] == 3'b010) ? A_and_B :
                 (ALU_control[2:0] == 3'b011) ? A_or_B  :
                 (ALU_control[2:0] == 3'b100) ? A_xor_B  :
                 (ALU_control[2:0] == 3'b101) ? slt:
                 (ALU_control[2:0] == 3'b110) ? A_sll_B:
                  A_srl_B; 


  assign ALU_output = mux_2;

  //zero flag
  assign z = &(~ALU_output);
  // negative flag
  assign n = ALU_output[31];
  // carry flag
  assign c = cout & (~ALU_control[1]);
  // overflow flag
  assign v = (~ALU_control[1]) & (ALU_A[31] ^ sum[31]) & (~(ALU_A[31] ^ ALU_B[31] ^ ALU_control[0]));
  
  assign j = v ^ sum[31];

  assign slt = {31'b0000000000000000000000000000000,j};

endmodule
