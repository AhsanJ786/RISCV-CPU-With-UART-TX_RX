
module Single_Cycle_Top(clk,rst,e_inter,t_inter);
input logic clk,rst,e_inter,t_inter;

wire [31:0] PC_top,RD_Instr,RD1_Top,Imm_Ext_Top,ALU_OUTPUT_TOP,ReadData,pc_plus_4,RD2_Top,result,Alu_Src_B,pc_for_branch,result_pc,JALR_mux_out;

wire [2:0]ALUControl_Top,ImmSrc_Top,ResultSrc_top;

wire Regwrite_Top,Memwrite_Top,AluSrc_Top,zero_top,PcSrc_top,negative_top,Jalr_mux_sel_Top;

// pipeline signals
wire [31:0] PC_Fetch,RD_Instr_Fetch,pc_plus_4_Fetch,pc_plus_4_Execute,RD_Instr_Execute,pc_for_branch_execute;
wire [31:0] RD2_Top_Execute,ALU_OUTPUT_TOP_EXecute,forward_a_out,forward_b_out,Pc_Execute,Imm_Execute,forwa_Top_Execute;
wire [2:0] ResultSrc_top_Execute;
wire Regwrite_Top_Execute,Memwrite_Top_Execute,ForwardA_top,ForwardB_top,stall_top,stall_mw_top;
wire flush_top;
// LSU and UART 
wire [31:0] RD_uart,UBD_top,UC_top,UD_top,uart_dmm_out;
wire uart_sel_top,dmm_sel_top,serial_out_top;
wire [3:0] bit_cnt_out_top;
wire serial_in_rs,byte_ready_Rs;
wire [7:0] data_out_rs;
//csr
wire [31:0] csrrw_top_wb,epc_top,pc_final;
wire csr_rde_top,csr_wre_top,csr_wre_top_Execute,csr_rde_top_Execute,is_mret_top,is_mret_top_Execute;
wire epc_taken_top,tx_intr_top,rx_intr_top;
                         // pc counter module
pc_module Pc(     .clk(clk),                 
                  .rst(rst),
                  .PC(PC_top),
                  .PC_Next(pc_final),
                  .stall(stall_top));
                        //pipeline(PC_Fetch)
register PC_F(    .clk(clk),
                  .rst(rst),
                  .in(PC_top),
                  .out(PC_Fetch),
                  .stall(stall_top)); 

                       //pipeline (Pc_Execute)   
register PC_E(    .clk(clk),
                  .rst(rst),
                  .in(PC_Fetch),
                  .out(Pc_Execute),
                  .stall(stall_mw_top));                

                        //instructon memory
instruction_memory Instructions_memory(
                  .A(PC_top),
                  .rst(rst),
                  .Rd(RD_Instr));
                        //pipeline (instruction Fetch)
register_flush Instruction_Fetch(
                  .clk(clk),
                  .rst(rst),
                  .in(RD_Instr),
                  .out(RD_Instr_Fetch),
                  .stall(stall_top),
                  .flush(flush_top)); 
                        //pipeline (instruction execute)
register Instruction_execute(
                  .clk(clk),
                  .rst(rst),
                  .in(RD_Instr_Fetch),
                  .out(RD_Instr_Execute),
                  .stall(stall_mw_top)); 
                        //PC adder for +4
pc_adder  PC_Adder_plus4(
                  .a(PC_top),
                  .b(32'd4),
                  .c(pc_plus_4));

                        // pipeline (PC + 4 Fetch)
register PC_Plus_4_Fetch(
                  .clk(clk),
                  .rst(rst),
                  .in(pc_plus_4),
                  .out(pc_plus_4_Fetch),
                  .stall(stall_top)); 
                       // pipeline (PC + 4 Execute)
register PC_Plus_4_Execute(
                  .clk(clk),
                  .rst(rst),
                  .in(pc_plus_4_Fetch),
                  .out(pc_plus_4_Execute),
                  .stall(stall_mw_top));

                         // Register file
registerfile RegisterFile(.A1(RD_Instr_Fetch[19:15]),
                          .A2(RD_Instr_Fetch[24:20]),
                          .A3(RD_Instr_Execute[11:7]),
                          .RD1(RD1_Top),
                          .RD2(RD2_Top),
                          .WE3(Regwrite_Top_Execute),
                          .WD3(result),
                          .reset(rst),
                          .clk(clk));
                         // pipeline (write data execute)
register RD_2_Execute(.clk(clk),
              .rst(rst),
              .in(forward_b_out),
              .out(RD2_Top_Execute),
              .stall(stall_mw_top)); 

                          //immediate generator
sign_ext Sign_exts(.In(RD_Instr_Fetch),
                  .Imm_ext(Imm_Ext_Top),
                  .ImmSrc(ImmSrc_Top));
                         
                         // reg for immediate value
  
register IMM_Execute(   .clk(clk),
                        .rst(rst),
                        .in(Imm_Ext_Top),
                        .out(Imm_Execute),
                        .stall(stall_mw_top)); 
                     
                          // mux between alu and reg file(rd2 and imm ext)

mux  Mux_Rg_ALu(.a(forward_b_out),
                 .b(Imm_Ext_Top),
                 .c(Alu_Src_B),
                 .s(AluSrc_Top));
                         //forwading ALu src A
mux Mux_Forwad_a(.a(RD1_Top),
                 .b(ALU_OUTPUT_TOP_EXecute),
                 .c(forward_a_out),
                 .s(ForwardA_top));
                        //forwading ALu src B
mux Mux_Forwad_b(.a(RD2_Top),
                 .b(ALU_OUTPUT_TOP_EXecute),
                 .c(forward_b_out),
                 .s(ForwardB_top));
                        // pipeline (forw a execute)
register forw_a_Execute(.clk(clk),
              .rst(rst),
              .in(forward_a_out),
              .out(forwa_Top_Execute),
              .stall(stall_mw_top)); 
                          //Alu

alu ALU(.ALU_A(forward_a_out),
        .ALU_B(Alu_Src_B),
        .ALU_control(ALUControl_Top),
        .ALU_output(ALU_OUTPUT_TOP),
        .z(zero_top),
        .n(negative_top),
        .v(),
        .c());
                       // pipeline (ALU execute)
register ALU_Execute(.clk(clk),
              .rst(rst),
              .in(ALU_OUTPUT_TOP),
              .out(ALU_OUTPUT_TOP_EXecute),
              .stall(stall_mw_top)); 
                       //control unit

control_unit_top CU(.op(RD_Instr_Fetch[6:0]),
                    .zero(zero_top),
                    .Regwrite(Regwrite_Top),
                    .Memwrite(Memwrite_Top),
                    .ResultSrc(ResultSrc_top),
                    .AluSrc(AluSrc_Top),
                    .ImmSrc(ImmSrc_Top),
                    .PcSrc(PcSrc_top),
                    .funct3(RD_Instr_Fetch[14:12]),
                    .funct7(RD_Instr_Fetch[31:25]),
                    .ALU_control(ALUControl_Top),
                    .negative(negative_top),
                    .Jalr_mux_sel(Jalr_mux_sel_Top),
                    .csr_wre(csr_wre_top),
                    .csr_rde(csr_rde_top),
                    .is_mret(is_mret_top));

                     // pipeline (Control signal Resultsrc execute)
register_3bit Resultsrc_Execute(.clk(clk),
              .rst(rst),
              .in(ResultSrc_top),
              .out(ResultSrc_top_Execute),
              .stall(stall_mw_top)); 
                    
                    // pipeline (Control signal regwrite execute)
register_1bit Regwrite_Executes(.clk(clk),
              .rst(rst),
              .in(Regwrite_Top),
              .out(Regwrite_Top_Execute),
              .stall(stall_mw_top)); 
                  // pipeline (Control signal csr_wre execute)
register_1bit CSR_WRE_Executes(.clk(clk),
              .rst(rst),
              .in(csr_wre_top),
              .out(csr_wre_top_Execute),
              .stall(stall_mw_top)); 
                // pipeline (Control signal csr_rde execute)
register_1bit CSR_RDE_Executes(.clk(clk),
              .rst(rst),
              .in(csr_rde_top),
              .out(csr_rde_top_Execute),
              .stall(stall_mw_top)); 
                  // pipeline (Control signal is_mret execute)
register_1bit ismret_Executes(.clk(clk),
              .rst(rst),
              .in(is_mret_top),
              .out(is_mret_top_Execute),
              .stall(stall_mw_top));   
                    // pipeline (Control signal memwrite execute)
register_1bit Memwrite_Executes(.clk(clk),
              .rst(rst),
              .in(Memwrite_Top),
              .out(Memwrite_Top_Execute),
              .stall(stall_mw_top)); 

                     // choosing input of pc branch

mux_PCSRC Mux_Reg_PC_Addder_branchs(.a(PC_Fetch),
                 .b(forward_a_out),
                 .c(JALR_mux_out),
                 .s(Jalr_mux_sel_Top));
                    // pc adder for branch

pc_adder  PC_Adder_branch(.a(JALR_mux_out),
                   .b(Imm_Ext_Top),
                   .c(pc_for_branch));
                     // pipeline (PC_branch Execute)
register PC_branch_Execute(.clk(clk),
              .rst(rst),
              .in(pc_for_branch),
              .out(pc_for_branch_execute),
              .stall(stall_mw_top));
                    // LS Unit
lsu      LSU(.op(RD_Instr_Execute[6:0]),
             .alu_out(ALU_OUTPUT_TOP_EXecute),
             .uart_sel(uart_sel_top),
             .dmm_sel(dmm_sel_top));

                     //data memory

data_memory Data_memory(.A(ALU_OUTPUT_TOP_EXecute),
                        .clk(clk),
                        .WE(Memwrite_Top_Execute),
                        .WD(RD2_Top_Execute),
                        .RD(ReadData),
                        .dmm_sel(dmm_sel_top));

                   // uart registers
uart_regfile  Uart_Regfile(.A(ALU_OUTPUT_TOP_EXecute),
                              .clk(clk),
                              .WE(Memwrite_Top_Execute),
                              .WD(RD2_Top_Execute),
                              .RD(RD_uart),
                              .uart_sel(uart_sel_top),
                              .uart_baud_divisor_out(UBD_top),
                              .uart_data_out(UD_top),
                              .uart_tx_control_out(UC_top),
                              .rst(rst),
                              .bit_cnt_out(bit_cnt_out_top),
                              .rec_data(data_out_rs),
                              .ready_rec(byte_ready_Rs),
                              .tx_intr(tx_intr_top),
                              .rx_intr(rx_intr_top)); 
                  // mux to choose uart and dmm
 mux          mux_uart_dmm   (.a(ReadData),
                              .b(RD_uart),
                              .c(uart_dmm_out),
                              .s(uart_sel_top));

                     // mux between data mem and reg file
mux_8x1  MUX_result (.a(ALU_OUTPUT_TOP_EXecute),
                     .b(uart_dmm_out),
                     .c(pc_plus_4_Execute),
                     .d(pc_for_branch_execute),
                     .e(csrrw_top_wb),
                     .s(ResultSrc_top_Execute),
                     .out(result));


                    // mux for choosing branch
mux_PCSRC  MUX_Result_Pc (.a(pc_plus_4),
                 .b(pc_for_branch),
                 .c(result_pc),
                 .s(PcSrc_top));
                   // forwadding unit
forwading_unit Forwading_Unit(
   .MEM_DestReg(RD_Instr_Execute[11:7]),
   .MEM_RegWrite(Regwrite_Top_Execute),
   .EXE_SrcReg1(RD_Instr_Fetch[19:15]),
   .EXE_SrcReg2(RD_Instr_Fetch[24:20]),
   .ForwardA(ForwardA_top),
   .ForwardB(ForwardB_top),
   .stall(stall_top),
   .op_mw(RD_Instr_Execute[6:0]),
   .stall_mw(stall_mw_top),    
   .flush(flush_top),
   .op_ed(RD_Instr_Fetch[6:0]),
   .pcsrc(PcSrc_top),
   .clk(clk),
   .rst(rst));
                // uart tx top
 uart_system_top uart(.clk(clk),
                                    .rst(rst),
                                    .data_in(UD_top[7:0]),
                                    .transfer_byte(UC_top[0]),
                                    .byte_ready(1'b1),
                                    .load_data_reg(UD_top[31]),
                                    .serial_out(serial_out_top),
                                    .dvsr(UBD_top),
                                    .bit_cnt_out(bit_cnt_out_top),
                                    .stop_2(UC_top[1]));
                  // uart rx top
uart_res_top  uartres(.clk(clk),
.rst(rst),
.dvsr(UBD_top),
.serial_in(serial_out_top),
.byte_ready(byte_ready_Rs),
.data_out(data_out_rs));

            // csr regfile
csr_regfile CSR_Reg(.clk(clk),
.rst(rst),
.pc(Pc_Execute),
.csr_addr(Imm_Execute[11:0]),
.csr_wr(csr_wre_top_Execute),
.csr_rd(csr_rde_top_Execute),
.is_mret(is_mret_top_Execute),
.wd(forwa_Top_Execute),
.rd(csrrw_top_wb),
.t_inter(t_inter),
.e_inter(e_inter),
.epc(epc_top),
.epc_taken(epc_taken_top),
.tx_intr(tx_intr_top),
.rx_intr(rx_intr_top));
           // mux
mux_PCSRC   MUX_PC_Ultimate(  .a(result_pc),
                        .b(epc_top),
                        .c(pc_final),
                        .s(epc_taken_top));
endmodule