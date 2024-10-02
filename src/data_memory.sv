module data_memory(A,clk,WE,WD,RD,dmm_sel);
input clk,WE,dmm_sel;
input [31:0] A,WD;
output [31:0] RD;

reg [31:0] data_mmory [1023:0];

assign RD = ( ~WE & dmm_sel) ? data_mmory[A] : 32'h00000000;

always @(posedge clk)
begin
    

       if (WE & dmm_sel)begin
          data_mmory[A] <= WD;
        
       end
end
initial begin
   data_mmory[1] = 5;
   data_mmory[12] = 5;
   data_mmory[13] = 5;
end
    
endmodule