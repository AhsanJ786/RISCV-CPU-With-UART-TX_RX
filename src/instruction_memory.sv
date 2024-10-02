module instruction_memory(A,rst,Rd);

input [31:0]A;
input rst;
output [31:0]Rd;

reg [31:0] mem [1023:0];

assign Rd = (~rst)? 32'h00000000 : mem[A[31:2]];
/*initial begin
  $readmemh("memfile.hex",mem);
end*/

initial begin
   //mem[0] = 32'hFFC4A303;  //(lw) 
   //mem[0] = 32'h0064A423;  //(sw)
   //mem[0] = 32'h0062E233;  //(r type)
   //mem[2] = 32'hFE420AE3;  //(beq)
   //mem[1] = 32'h00C48413;    // (i)
   //mem[2] = 32'hFF230913;     //(i)
   //mem[7] = 32'h7F8A60EF;     //(jal)
   //mem[8] = 32'h0020C263;  //(branch less than)
   //mem[9] = 32'h00555463;   //(branch grater or equal to signed)
   //mem[0] = 32'h00ABC297;   //(Auipc) 
   //sw for uart
   mem[0] = 32'h00E4A023; 
   mem[1] = 32'h00A42023; 
   mem[2] = 32'h00D58023; 
   mem[3] = 32'h0128A023;
   mem[4] = 32'h30009073;
   mem[5] = 32'h30411073;
   mem[6] = 32'h30519073;
   mem[616]= 32'hFFC4A303;
    
    /*mem[0] = 32'h30009073; 
    mem[1] = 32'h30411073; 
    mem[2] = 32'h30519073;
    mem[3] = 32'h00170713;
    mem[4] = 32'h00170713;
    mem[5] = 32'h00170713;
    mem[6] = 32'h00170713;
    mem[7] = 32'h00170713;
    mem[8] = 32'h00170713;
    mem[9] = 32'h00170713;
    mem[10] = 32'h00170713;
    mem[11] = 32'h00170713;
    mem[12] = 32'h00170713;
    mem[13] = 32'h00170713;
    mem[14] = 32'h30431073;
    mem[15] = 32'h00170713;
    mem[16] = 32'h00000073;*/

    




    
end



endmodule