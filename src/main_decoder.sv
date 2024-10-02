module main_decoder(
    input logic [6:0] op,
    input logic zero, negative,
    input logic [2:0] funct3,
    output logic Regwrite, Memwrite, AluSrc, PcSrc, Jalr_mux_sel,csr_wre,csr_rde,is_mret,
    output logic [1:0]  AluOp,
    output logic [2:0] ResultSrc,ImmSrc
);

    // Define enum for operation codes
    typedef enum logic [6:0] {
        LOAD = 7'b0000011,
        STORE = 7'b0100011,
        OP_IMM = 7'b0010011,
        BRANCH = 7'b1100011,
        JAL = 7'b1101111,
        JALR = 7'b1100111,
        LUI = 7'b0010111,
        AUIPC = 7'b0110111,
        CSR   = 7'b1110011,
        OP = 7'b0110011
    } OpCode;

    // Wire declaration
    logic branch, jump;

    assign Regwrite   = (op == LOAD || op == CSR || op == OP || op == OP_IMM || op == JAL || op == LUI || op == JALR) ? 1'b1 : 1'b0;
    assign Memwrite   = (op == STORE) ? 1'b1 : 1'b0;

    assign ResultSrc  = (op == LOAD) ? 3'b001 :
                        (op == JAL || op == JALR) ? 3'b010 :
                        (op == LUI) ? 3'b011 :
                        (op == CSR) ? 3'b100 :3'b000;

    assign AluSrc     = (op == LOAD || op == STORE || op == OP_IMM) ? 1'b1 : 1'b0;

    assign branch     = (op == BRANCH) ? 1'b1 : 1'b0;

    assign ImmSrc     = (op == STORE) ? 3'b001 :
                        (op == BRANCH) ? 3'b010 :
                        (op == JAL) ? 3'b011 :
                        ((op == LOAD) || (op == OP_IMM) || (op == JALR) || (op == CSR)) ? 3'b000 :
                        (op == LUI) ? 3'b100 : 3'b000;

    assign AluOp      = (op == OP || op == OP_IMM) ? 2'b10 :
                        (op == BRANCH) ? 2'b01 : 2'b00;

    assign jump       = (op == JAL || op == JALR) ? 1'b1 : 1'b0;

    assign Jalr_mux_sel = (op != JALR) ? 1'b0 : 1'b1;

    assign PcSrc      = (jump || (zero && branch) || (negative && branch) || (branch && (zero || (~negative))));
    
    assign csr_wre  = ((op == CSR ) && ( funct3 != 3'b000)) ? 1'b1 : 1'b0;

    assign csr_rde  = ((op == CSR ) && ( funct3 != 3'b000))  ? 1'b1 : 1'b0;

    assign is_mret  = ((op == CSR ) && ( funct3 == 3'b000))  ? 1'b1 : 1'b0;
endmodule
