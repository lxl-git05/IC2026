//=======================================
// OPCODE 定义（7-bit）
//=======================================
`define INSTR_RTYPE_OP     7'b0110011   // R-type
`define INSTR_ITYPE_OP     7'b0010011   // I-type (ALU)
`define INSTR_BTYPE_OP     7'b1100011   // B-type (Branch)
`define INSTR_LW_OP        7'b0000011   // LW
`define INSTR_SW_OP        7'b0100011   // SW
`define INSTR_JAL_OP       7'b1101111   // JAL
`define INSTR_JALR_OP      7'b1100111   // JALR

//=======================================
// R-type Funct7 + Funct3 定义
//=======================================
`define INSTR_ADD_FUNCT    10'b0000000_000   // ADD
`define INSTR_SUB_FUNCT    10'b0100000_000   // SUB
`define INSTR_SUBU_FUNCT   6'b100011         // SUBU (部分编码可能简化)
`define INSTR_AND_FUNCT    10'b0000000_111   // AND
`define INSTR_OR_FUNCT     10'b0000000_110   // OR
`define INSTR_XOR_FUNCT    10'b0000000_100   // XOR
`define INSTR_NOR_FUNCT    6'b100111         // NOR
`define INSTR_SLL_FUNCT    10'b0000000_001   // SLL
`define INSTR_SRL_FUNCT    10'b0000000_101   // SRL
`define INSTR_SRA_FUNCT    10'b0100000_101   // SRA
`define INSTR_SRLV_FUNCT   6'b000110         // SRLV
`define INSTR_SRAV_FUNCT   6'b000111         // SRAV
`define INSTR_SLLV_FUNCT   6'b000100         // SLLV
`define INSTR_JR_FUNCT     6'b001000         // JR

//=======================================
// B-type Funct3 定义
//=======================================
`define INSTR_BEQ_FUNCT    3'b000   // BEQ
`define INSTR_BNE_FUNCT    3'b001   // BNE

//=======================================
// I-type Funct3 定义（部分）
//=======================================
`define INSTR_ADDI_FUNCT   3'b000   // ADDI
`define INSTR_ORI_FUNCT    3'b110   // ORI
