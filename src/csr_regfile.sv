module csr_regfile (tx_intr,rx_intr,clk,rst,pc,csr_addr,csr_wr,csr_rd,is_mret,wd,rd,t_inter,e_inter,epc,epc_taken);
input logic clk,rst,csr_rd,csr_wr,is_mret;
input logic  t_inter,e_inter;
input logic tx_intr,rx_intr;
input logic [11:0] csr_addr;
input logic [31:0] pc,wd;
output logic epc_taken;
output logic [31:0] rd,epc;

// memory mapped registers

localparam mstatus_addr = 12'h300;
localparam mie_addr = 12'h304;
localparam mtvec_addr = 12'h305;
localparam mepc_addr = 12'h341;
localparam mcause_addr = 12'h342;
localparam mip_addr = 12'h344;


reg [31:0] mstatus_reg;
reg [31:0] mie_reg;
reg [31:0] mtvec_reg;
reg [31:0] mepc_reg;
reg [31:0] mcause_reg;
reg [31:0] mip_reg;
                //flags
logic inter_flag;

                // for reading the csr registers
always_comb begin 
    rd = 32'd0;
    if (csr_rd) begin
        case (csr_addr)
        mstatus_addr : rd = mstatus_reg;
        mie_addr : rd     = mie_reg;
        mtvec_addr : rd   = mtvec_reg;
        mepc_addr : rd    = mepc_reg;
        mcause_addr : rd  = mcause_reg;
        mip_addr : rd     = mip_reg;
            
        endcase
    end   
end
             // for writing
always@( posedge clk or negedge rst)begin
    if ( ~rst )begin
        mstatus_reg <= 0;
        mie_reg     <= 0;
        mtvec_reg   <= 0;
        mip_reg     <= 0;
    end
    else if ( csr_wr) begin
        case (csr_addr)
        mstatus_addr : begin 
        mstatus_reg <= wd;
        mstatus_reg[0] <= 1'b0;
        mstatus_reg[2] <= 1'b0;
        mstatus_reg[4] <= 1'b0;
        mstatus_reg[30:23] <= 8'b0;
        mstatus_reg[17] <= 1'b0;
        mstatus_reg[18] <= 1'b0;
        mstatus_reg[19] <= 1'b0;
        mstatus_reg[6] <= 1'b0;
        mstatus_reg[20] <= 1'b0;
        mstatus_reg[21] <= 1'b0;
        mstatus_reg[14:13] <= 2'b0;
        mstatus_reg[10:9] <= 2'b0;
        mstatus_reg[16:15] <= 2'b0;
        mstatus_reg[31] <= 1'b0;
            end
        mtvec_addr :  begin  
        mtvec_reg[31:2]<= wd;
        mtvec_reg[1:0]<= 0; // mode is direct mode
        end
        mie_addr :      mie_reg     <= wd;
            
        endcase
    end
end
always_comb begin
    if (e_inter) begin
        mip_reg[11]=1'b1;
    end
    else if (t_inter) begin
        mip_reg[7]=1'b1;
    end
end
                // for uart interrupt
always_comb begin
      if (tx_intr | rx_intr) begin 
        mip_reg[16] = 1'b1;
      end
end
/*always@(e_inter or t_inter) begin
    if ((e_inter == 1'b1)||(t_inter == 1'b1)) begin
        inter_flag =((mip_reg[11] && mie_reg[11])||(mie_reg[7] && mie_reg[7])) && mstatus_reg[3];
    end
    else begin
        inter_flag =1'b0;
    end
end*/
always@(tx_intr or rx_intr)begin
    if((tx_intr == 1'b1) || (rx_intr == 1'b1) )begin
        inter_flag = (mip_reg[16] & mie_reg[16]) & mstatus_reg[3];
    end
     else begin
        inter_flag =1'b0;
    end
end
always_ff @(posedge clk) begin
    if (inter_flag) begin
        mepc_reg <= pc;
        mcause_reg[31] <= 1'b1;
        mcause_reg[30:0] <= 31'd16;       
    end
    else if (!inter_flag) begin 
        if (is_mret) begin
            mcause_reg[31:0] <= 32'd0;  
        end
    end
end
always_comb begin
    if (inter_flag) begin
        epc      = {{2{1'b0}},mtvec_reg[31:2]};
        epc_taken= 1'b1; 
        
    end
    else if (!inter_flag) begin 
        if (is_mret) begin
            epc = mepc_reg; 
            epc_taken = 1'b1; 
        end
        else begin
        epc_taken =1'b0;
    end
    end
end
   
endmodule