module register_flush(clk,rst,in,out,stall,flush);
input wire clk;
input wire rst,stall,flush;
input wire [31:0] in;
output reg [31:0] out;

  always @(posedge clk)
    begin
        if ( rst == 1'b0)
        begin
            out <= 32'h00000000;
        end
        else if ( stall == 1'b1) 
        begin
            out <= out ;
        end
        else if ( flush == 1'b1) 
        begin
            out <= 32'h00000013;
        end
        else
        begin
            out <= in;
        end
    end


endmodule