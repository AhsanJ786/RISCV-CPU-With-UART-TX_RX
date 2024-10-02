module registerfile(A1,A2,A3,RD1,RD2,WE3,WD3,reset,clk);
  input clk,reset,WE3;
  input [4:0] A1,A2,A3;
  input [31:0] WD3;
  output [31:0] RD1,RD2;

  reg [31:0] register [31:0];

  always @(posedge clk)
        begin
            if ((WE3) & (A3 != 5'b00000))
            begin
               register[A3] <= WD3;
        end
        end
    assign RD1 = ((reset == 1'b0) | (A1 == 5'b00000))? 32'h00000000 : register[A1];
    assign RD2 = ((reset == 1'b0) | (A2 == 5'b00000))? 32'h00000000 : register[A2];

    initial begin
       register[9] = 32'h80000000;
       register[6] = 32'h00000000;
       register[5] = 32'h00000006;
       register[4] = 32'h00000004;
       register[1] = 32'h00000008;
       register[2] = 32'h00010000;
       register[10] = 32'h00000030;
       register[3] = 32'h000009A0;
       register[7] = 32'h00000101;
       register[8] = 32'h80000004;
       register[11] = 32'h80000008;
       register[12] = 32'h00000001;
       register[13] = 32'h00000003;
       register[14] = 32'h00000011;
       register[15] = 32'h80000008;
       register[16] = 32'h00000001;
       register[17] = 32'h80000010;
       register[18] = 32'h00000002;
       register[19] = 32'h80000000;
       register[20] = 32'h00000001;


   end
    
endmodule