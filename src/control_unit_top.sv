

module control_unit_top(is_mret,csr_wre,csr_rde,op,negative,zero,Regwrite,Memwrite,ResultSrc,AluSrc,ImmSrc,PcSrc,funct3,funct7,ALU_control,Jalr_mux_sel);
      input [6:0]op,funct7;
      input [2:0]funct3;
      input zero,negative;
      output Regwrite,AluSrc,Memwrite,PcSrc,Jalr_mux_sel,csr_wre,csr_rde,is_mret;
      output [2:0]ALU_control,ImmSrc,ResultSrc;

      wire [1:0]AluOp;

      main_decoder main_decoder(.op(op),
                                .zero(zero),
                                .Regwrite(Regwrite),
                                .Memwrite(Memwrite),
                                .ResultSrc(ResultSrc),
                                .AluSrc(AluSrc),
                                .ImmSrc(ImmSrc),
                                .PcSrc(PcSrc),
                                .AluOp(AluOp),
                                .negative(negative),
                                .Jalr_mux_sel(Jalr_mux_sel),
                                .csr_wre(csr_wre),
                                .csr_rde(csr_rde),
                                .funct3(funct3),
                                .is_mret(is_mret));
      
      alu_decoders Alu_decoder(.AluOp(AluOp),
                              .funct3(funct3),
                              .funct7(funct7),
                              .op(op),
                              .ALU_control(ALU_control));

      


endmodule