
module pc_module(clk,rst,PC,PC_Next,stall);
    input clk,rst,stall;
    input [31:0]PC_Next;
    output [31:0]PC;
    reg [31:0]PC;

    always @(posedge clk)
    begin
        if ( rst == 1'b0)
        begin
            PC <= 32'h00000000;
        end
        else if ( stall == 1'b1) 
        begin
            PC <= PC ;
        end
        else
        begin
            PC <= PC_Next;
        end
    end
endmodule