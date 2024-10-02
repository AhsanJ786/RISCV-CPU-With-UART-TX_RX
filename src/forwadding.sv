module forwading_unit (
   clk,rst,MEM_DestReg,MEM_RegWrite,EXE_SrcReg1,EXE_SrcReg2,ForwardA,ForwardB,stall,op_mw,stall_mw,flush,op_ed,pcsrc    
);
input  wire [6:0] op_mw,op_ed;
input  wire [4:0] MEM_DestReg, EXE_SrcReg1,EXE_SrcReg2;
input  wire MEM_RegWrite,pcsrc;
output reg ForwardA,ForwardB,stall,stall_mw,flush;
reg stall_time;
input wire clk,rst;


always @(*) begin
    if (op_mw != 7'b0000011) begin
    // Forward from MW to DE stage for SrcReg1
    ForwardA = (MEM_RegWrite & (MEM_DestReg != 0) & (MEM_DestReg == EXE_SrcReg1));
    // Forward from MW to DE stage for SrcReg2
    ForwardB = (MEM_RegWrite & (MEM_DestReg != 0) & (MEM_DestReg == EXE_SrcReg2));
end
end

reg stalled_last_cycle; // Register to keep track of a stall in the previous cycle

always @(negedge clk or negedge rst) begin
    if (!rst) begin
        // Asynchronous reset
        stall <= 1'b0;
        stall_mw <= 1'b0;
        stalled_last_cycle <= 1'b0; // Reset the stall tracking on reset
    end else begin
        if (op_mw == 7'b0000011) begin
            if (MEM_RegWrite && ((MEM_DestReg == EXE_SrcReg1) || (MEM_DestReg == EXE_SrcReg2)) && !stalled_last_cycle) begin
                // Stall if required and not already stalled last cycle
                stall <= 1'b1;
                stall_mw <= 1'b1;
                stalled_last_cycle <= 1'b1; // Mark that we have stalled this cycle
            end else begin
                // Reset stall signals and mark that we are not stalling this cycle
                stall <= 1'b0;
                stall_mw <= 1'b0;
                stalled_last_cycle <= 1'b0;
            end
        end else begin
            // If the operation is not a load, ensure stall signals are reset
            stall <= 1'b0;
            stall_mw <= 1'b0;
            stalled_last_cycle <= 1'b0; // No stall this cycle
        end
    end
end


always @(*) begin
    //check if branch is taken then we will flush
    if (((op_ed == 7'b1101111)|(op_ed == 7'b1100111)| (op_ed == 7'b1100011)) & (pcsrc == 1'b1))
    begin
        flush = 1'b1;
    end
    else begin
        flush = 1'b0;
    end
end
endmodule