`include "Ctrl-signal-def.v"
`include "instruction-def.v"
module riscv(clk, rst);
    input clk, rst;

    wire RFWrite, DMCtrl, PCWrite, IRWrite, InsMemRW, ExtSel, zero;
    wire [1:0] ALUSrcA; // 位宽修改
    wire [2:0] ALUSrcB; // 位宽修改
    wire [1:0] NPCOp, WDSel, RegSel;
    wire [3:0] ALUOp;
    wire [6:0] opcode;
    wire [2:0] Funct3;
    wire [6:0] Funct7;
    wire [31:0] PC, NPC, PCA4;
    wire [31:0] in_ins, out_ins, RD, DR_out;
    wire [4:0] rs1, rs2, rd;
    wire [11:0] Imm12;
    wire [31:0] Imm32;
    wire [20:1] Offset20;
    wire [11:0] Offset;
    wire [4:0] WR;
    wire [31:0] WD;
    wire [31:0] RD1, RD1_r, RD2, RD2_r;
    wire [31:0] A, B, ALU_result, ALU_result_r;

    assign opcode   = out_ins[6:0];
    assign Funct3   = out_ins[14:12];
    assign Funct7   = out_ins[31:25];
    assign rs1      = out_ins[19:15];
    assign rs2      = out_ins[24:20];
    assign rd       = out_ins[11:7];
    // I型指令(12位),用于addi,ori,lw,jalr
    assign Imm12    = out_ins[31:20];
    // jal[20:1] = {out_ins[31], out_ins[19:12], out_ins[20], out_ins[30:21]}
    assign Offset20 = {out_ins[31],out_ins[19:12],out_ins[20],out_ins[30:21]};
    // INSTR_BTYPE_OP->branch[12:1]  INSTR_SW_OP->sw 否则->I型指令
    assign Offset   = (opcode == `INSTR_BTYPE_OP) ? {out_ins[31],out_ins[7],out_ins[30:25],out_ins[11:8]} :
                      (opcode == `INSTR_SW_OP)    ? {out_ins[31:25],out_ins[11:7]} : Imm12;
    
    wire flush ;    // 新增:IR冲刷信号
    
    // ControlUnit
    ControlUnit U_ControlUnit(
        .clk(clk), .rst(rst), .zero(zero), .opcode(opcode), .Funct7(Funct7), .Funct3(Funct3),
        .RFWrite(RFWrite), .DMCtrl(DMCtrl), .PCWrite(PCWrite), .IRWrite(IRWrite), .InsMemRW(InsMemRW),
        .ExtSel(ExtSel), .ALUOp(ALUOp), .NPCOp(NPCOp), .ALUSrcA(ALUSrcA),
        .WDSel(WDSel), .ALUSrcB(ALUSrcB), .RegSel(RegSel), .rs1(rs1) , .rs2(rs2) , .rd(rd) , .flush(flush)
    );

    // PC
    PC U_PC (
        .clk(clk), .rst(rst), .PCWrite(PCWrite), .NPC(NPC), .PC(PC)
    );

    // NPC,必须新增A,因为一旦产生数据冲突,rd1作为旧值会产生错误
    NPC U_NPC (
        .clk(clk), .rst(rst), .PC(PC), .NPCOp(NPCOp), .Offset12(Offset), .Offset20(Offset20), .rs(RD1), .PCA4(PCA4), .NPC(NPC), .rs_A(A)
    );

    // IM
    IM U_IM (
        .addr(PC[11:2]), .Ins(in_ins), .InsMemRW(InsMemRW)
    );

    // IR
    IR U_IR (
        .clk(clk), .IRWrite(IRWrite), .in_ins(in_ins), .out_ins(out_ins) , .flush(flush)
    );

    // RF
    RF U_RF (
        .RR1(rs1), .RR2(rs2), .WR(WR), .WD(WD), .clk(clk),
        .RFWrite(RFWrite), .RD1(RD1), .RD2(RD2)
    );

    // MUX_3to1 (for rd)
    MUX_3to1 U_MUX_3to1 (
        .X(rd), .Y(5'd0), .Z(5'd31), .control(RegSel), .out(WR)
    );

    // MUX_3to1_LMD
    MUX_3to1_LMD U_MUX_3to1_LMD (
        .clk(clk), .X(ALU_result_r), .Y(DR_out), .Z(PCA4), .control(WDSel), .out(WD)
    ); 

    // Flopr for RD1
    Flopr U_A (
        .clk(clk), .rst(rst), .in_data(RD1), .out_data(RD1_r)
    );

    // Flopr for RD2
    Flopr U_B (
        .clk(clk), .rst(rst), .in_data(RD2), .out_data(RD2_r)
    );

    // EXT
    EXT U_EXT (
        .imm_in(Imm12), .ExtSel(ExtSel), .imm_out(Imm32)
    );

    // MUX_2to1_A
    MUX_2to1_A U_MUX_2to1_A (
        .clk(clk), .X(RD1_r), .Y(32'h0), .ALU_result_r(ALU_result_r), .control(ALUSrcA), .out(A)
    );

    // MUX_3to1_B
    MUX_3to1_B U_MUX_3to1_B (
        .clk(clk), .X(RD2_r), .ALU_result_r(ALU_result_r), .Y(Imm32), .Z(Offset), .control(ALUSrcB), .out(B)
    );

    // ALU
    ALU U_ALU (
        .A(A), .B(B), .ALUOp(ALUOp), .ALU_result(ALU_result), .zero(zero)
    );

    // Flopr for ALU_result
    Flopr U_ALUOut (
        .clk(clk), .rst(rst), .in_data(ALU_result), .out_data(ALU_result_r)
    );

    // DM
    DM U_DM (
        .Addr(ALU_result_r[11:2]), .WD(RD2_r), .DMCtrl(DMCtrl), .clk(clk), .RD(RD)
    );

    // Flopr for DR (Data Register)
    Flopr U_DR (
        .clk(clk), .rst(rst), .in_data(RD), .out_data(DR_out)
    );
endmodule