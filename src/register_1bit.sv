module register_1bit(clk,rst,in,out,stall);
input wire clk;
input wire rst,stall;
input wire  in;
output reg out;

  always @(posedge clk)
    begin
        if ( rst == 1'b0)
        begin
            out <= 1'b0;
        end
         else if ( stall == 1'b1) 
        begin
            out <= out ;
        end
        else
        begin
            out <= in;
        end
    end


endmodule