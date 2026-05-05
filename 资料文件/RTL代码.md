## 1-0 Include

### 1-0-1 `Ctrl-signal-def.V`

```verilog
// NPC control signal
`define NPC_PC          2'b00
`define NPC_Offset12    2'b01
`define NPC_rs          2'b10
`define NPC_Offset20    2'b11

// A control signal
`define ALUSrcA_A       1'b0
`define ALUSrcA_sa      1'b1

// B control signal
`define ALUSrcB_B       2'b00
`define ALUSrcB_Imm     2'b01
`define ALUSrcB_Offset  2'b10
`define ALUSrcB_else    2'b11

// EXT control signal
`define ExtSel_ZERO     1'b0
`define ExtSel_SIGNED   1'b1

// ALU control signal
`define ALUop_ADD       4'b0000    // 加
`define ALUop_SUB       4'b0001    // 减
`define ALUop_AND       4'b0010    // 与
`define ALUop_OR        4'b0011    // 或
`define ALUop_XOR       4'b0100    // 异或
`define ALUop_SRA       4'b0101    // 算术右移
`define ALUop_SRL       4'b0110    // 逻辑右移
`define ALUop_SLL       4'b0111    // 逻辑左移
`define ALUop_BR        4'b1010    // 分支比较

// RF control signal
`define RegSel_rd       2'b00
`define RegSel_rt       2'b01
`define RegSel_31       2'b10
`define RegSel_else     2'b11

`define WDSel_FromALU   2'b00
`define WDSel_FromMEM   2'b01
`define WDSel_FromPC    2'b10
`define WDSel_Else      2'b11

// DM control signal
`define DMCtrl_RD       1'b0
`define DMCtrl_WR       1'b1

```



### 1-0-2 `Global-def.v`
```verilog
`define DEBUG 1

```


### 1-0-3 `Instruction-def.v`
```verilog
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

```


## 1-1 `ALU.v`
```verilog
`include "Ctrl-signal-def.v"
`include "instruction-def.v"
module ALU(A,B,ALUOp,zero,ALU_result);
    input signed [31:0] A;
    input signed [31:0] B;
    input [3:0] ALUOp;
    output zero;
    output reg signed [31:0] ALU_result;

    // 书写逻辑
    always @(*) begin
        case(ALUOp)

            4'b0000: ALU_result = A + B;                          // add
            4'b0001: ALU_result = A - B;                          // sub
            4'b0010: ALU_result = A & B;                          // and
            4'b0011: ALU_result = A | B;                          // or
            4'b0100: ALU_result = A ^ B;                          // xor
            4'b0101: ALU_result = A << B[4:0];                    // sll
            4'b0110: ALU_result = A >> B[4:0];                    // srl
            4'b0111: ALU_result = $signed(A) >>> B[4:0];          // sra
            4'b1000: ALU_result = ($signed(A) < $signed(B)) ?
                            32'd1 : 32'd0;                        // slt
            4'b1001: ALU_result = ($unsigned(A) < $unsigned(B)) ?
                            32'd1 : 32'd0;                       // sltu

            default: ALU_result = 32'b0;

        endcase
    end

    assign zero = (ALU_result == 32'b0);    // A != B, zero就为0

endmodule

```


## 1-2 `ControlUnit.v`
```verilog
`timescale 1ns / 1ps
`include "Ctrl-signal-def.v"
`include "instruction-def.v"
module ControlUnit(
    input rst,
    input clk,
    input zero,
    input [6:0] opcode,
    input [6:0] Funct7,
    input [2:0] Funct3,
    output reg PCWrite,
    output reg InsMemRW,
    output reg IRWrite,
    output reg RFWrite,
    output reg DMCtrl,
    output reg ExtSel,
    output reg ALUSrcA,
    output reg [1:0] ALUSrcB,
    output reg [1:0] RegSel,
    output reg [1:0] NPCOp,
    output reg [1:0] WDSel,
    output reg [3:0] ALUOp
);

endmodule
```


## 1-3 `  DM.v  `
```verilog
`include "Ctrl-signal-def.v"
module DM( Addr,WD,clk,DMCtrl,RD);

    input [11:2] Addr;
    input [31:0] WD;
    input clk;
    input DMCtrl;
    output reg [31:0] RD;

    reg [31:0] memory[0:1023];

    always @(posedge clk) begin
        if (DMCtrl) begin
            memory[Addr] <= WD;
        end
        else begin
            RD <= memory[Addr];
        end
    end // end always

endmodule

```


## 1-4  `  EXT.v  `
```verilog
`include "Ctrl-signal-def.v"
module EXT(imm_in,ExtSel, imm_out);

    input [11:0] imm_in;
    input ExtSel;
    output reg[31:0] imm_out;

    always@(imm_in or ExtSel) begin
        case(ExtSel)
            `ExtSel_ZERO :imm_out = {20'b0,imm_in[11:0]};
            `ExtSel_SIGNED:imm_out = {imm_in[11] ? 20'hfffff : 20'h00000 ,imm_in[11:0]};
            default     :imm_out = 32'b0;
        endcase
    end

endmodule
```


## 1-5 `  Flopr.v  `
```verilog
`include "Ctrl-signal-def.v"
module Flopr(clk,rst,in_data,out_data );

    input clk;
    input rst;
    input [31:0] in_data;
    output reg [31:0] out_data;

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            out_data <= 0;
        end
        else begin
            out_data <= in_data;
        end
    end

endmodule

```


## 1-6  `  IM.v ` 
```verilog
`include "Ctrl-signal-def.v"
module IM(InsMemRW, addr,Ins);

    input InsMemRW;
    input [11:2] addr;
    output reg [31:0] Ins;
    reg [31:0] memory[0:1023];

    always @(addr or InsMemRW) begin
        if (InsMemRW) begin
            Ins <= memory[addr];
        end
    end

endmodule

```


## 1-7 `  IR.v ` 
```verilog
`include "Ctrl-signal-def.v"
module IR(in_ins, clk, IRWrite, out_ins);

    input clk, IRWrite;
    input [31:0] in_ins;
    output reg[31:0] out_ins;

    always @(posedge clk) begin
        if (IRWrite) begin
            out_ins <= in_ins;
        end
    end

endmodule

```


## 1-8  `  MUX-2to1-A.v  `
```verilog
`include "Ctrl-signal-def.v"
module MUX_2to1_A(X,Y,control,out);

    input [31:0] X;
    input [4:0] Y;
    input control;
    output [31:0] out;

    assign out = (control == 1'b0 ? X : {27'b0,Y[4:0]});

endmodule

```


## 1-9 `  MUX-3to1.v ` 
```verilog
`include "Ctrl-signal-def.v"
module MUX_3to1(X,Y,Z,control,out);

    input [4:0] X;
    input [4:0] Y;
    input [4:0] Z;
    input [1:0] control;
    output reg[4:0] out;

    always @ (X or Y or Z or control) begin
        case(control)
            `RegSel_rd : out = X;
            `RegSel_rt : out = Y;
            `RegSel_31 : out = Z;
            `RegSel_else : out = 0;
        endcase
    end

endmodule

```


## 1-10  `  MUX-3to1-B.v ` 
```verilog
`include "Ctrl-signal-def.v"
module MUX_3to1_B(X,Y,Z,control,out);

    input [31:0] X;
    input [31:0] Y;
    input [11:0] Z;
    input [1:0] control;
    output reg signed [31:0] out;

    always @ (X or Y or Z or control) begin
        case(control)
            `ALUSrcB_B     : out = X;
            `ALUSrcB_Imm   : out = Y;
            `ALUSrcB_Offset: out = $signed(Z);
            `ALUSrcB_else  : out = X;
        endcase
    end

endmodule
```


## 1-11 `  MUX-3to1-LMD.v  `
```verilog
`include "Ctrl-signal-def.v"
module MUX_3to1_LMD(X,Y,Z,control,out);

    input [31:0] X;
    input [31:0] Y;
    input [31:2] Z;
    input [1:0] control;
    output reg[31:0] out;

    always @ (X or Y or Z or control) begin
        case(control)
            `WDSel_FromALU : out = X;
            `WDSel_FromMEM : out = Y;
            `WDSel_FromPC  : out = Z;
            `WDSel_Else    : out = 0;
        endcase
    end

endmodule

```


## 1-12 `  NPC.v  ` 
```verilog
`include "Ctrl-signal-def.v"
`include "instruction-def.v"
module NPC(NPCOp,Offset12,Offset20,PC,rs,PCA4, NPC);

    input [1:0] NPCOp;
    input [12:1] Offset12;
    input [20:1] Offset20;
    input [31:0] PC;
    input [31:0] rs;
    output reg [31:0] PCA4;
    output reg [31:0] NPC;

    wire signed [12:0] Offset13;
    wire signed [20:0] Offset21;

    assign Offset13 = $signed({Offset12[12:1],1'b0});
    assign Offset21 = $signed({Offset20[20:1],1'b0});

    always@(*) begin
        case(NPCOp)
            `NPC_PC       : NPC = PC + 4;
            `NPC_Offset12 : NPC = $signed({1'b0,PC}) + $signed(Offset13) ;
            `NPC_rs       : NPC = rs;
            `NPC_Offset20 : NPC = $signed({1'b0,PC}) + $signed(Offset21) ;
        endcase
        PCA4=PC+4;
    end

endmodule
```


## 1-13 `  PC.v ` 
```verilog
`include "Ctrl-signal-def.v"
module PC(clk,rst,PCWrite,NPC,PC);

    input clk;
    input rst;
    input PCWrite;
    input [31:0] NPC;
    output reg [31:0] PC;

    always @(posedge clk or posedge rst) begin
        // reset
        if (rst) begin
            PC <= 32'h0000_2000;
        end
        else if (PCWrite) begin
            PC <= NPC;
        end
    end

endmodule
```


## 1-14 `  RF.v  `
```verilog
`include "Ctrl-signal-def.v"
`include "instruction-def.v"
module RF(
    input [4:0] RR1,
    input [4:0] RR2,
    input [4:0] WR,
    input [31:0] WD,
    input RFWrite,
    input clk,
    output [31:0] RD1,
    output [31:0] RD2
);

    reg [31:0] register [0:31];

    always @(clk) begin
        register[0] = 32'h0;
    end

    always @(posedge clk) begin
        if ((WR != 0) && (RFWrite == 1)) begin
            register[WR] <= WD;
        end
    end

    assign RD1 = register[RR1];
    assign RD2 = register[RR2];

endmodule
```


## 1-15 `  Riscv.v ` 
```verilog
module riscv(clk, rst);
    input clk, rst;

    wire RFWrite, DMCtrl, PCWrite, IRWrite, InsMemRW, ExtSel, zero, ALUSrcA;
    wire [1:0] ALUSrcB;
    wire [1:0] NPCOp, WDSel, RegSel;
    wire [3:0] ALUOp;
    wire [6:0] opcode;
    wire [2:0] Funct3;
    wire [6:0] Funct7;
    wire [31:0] PC, NPC, PCA4;
    wire [31:0] in_ins, out_ins, RD, DR_out;
    wire [4:0] rs1, rs2, rd;
    wire [11:0] Imm12;
    wire [11:0] Imm32;
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
    // jal
    assign Offset20 = {out_ins[31],out_ins[19:12],out_ins[20],out_ins[30:21]};
    // INSTR_BTYPE_OP->branch  INSTR_SW_OP->sw 否则->I型指令
    assign Offset   = (opcode == `INSTR_BTYPE_OP) ? {out_ins[31],out_ins[7],out_ins[30:25],out_ins[11:8]} :
                      (opcode == `INSTR_SW_OP)    ? {out_ins[31:25],out_ins[11:7]} : Imm12;

    // ControlUnit
    ControlUnit U_ControlUnit(
        .clk(clk), .rst(rst), .zero(zero), .opcode(opcode), .Funct7(Funct7), .Funct3(Funct3),
        .RFWrite(RFWrite), .DMCtrl(DMCtrl), .PCWrite(PCWrite), .IRWrite(IRWrite), .InsMemRW(InsMemRW),
        .ExtSel(ExtSel), .ALUOp(ALUOp), .NPCOp(NPCOp), .ALUSrcA(ALUSrcA),
        .WDSel(WDSel), .ALUSrcB(ALUSrcB), .RegSel(RegSel)
    );

    // PC
    PC U_PC (
        .clk(clk), .rst(rst), .PCWrite(PCWrite), .NPC(NPC), .PC(PC)
    );

    // NPC
    NPC U_NPC (
        .PC(PC), .NPCOp(NPCOp), .Offset12(Offset), .Offset20(Offset20), .rs(RD1[31:2]), .PCA4(PCA4), .NPC(NPC)
    );

    // IM
    IM U_IM (
        .addr(PC[11:2]), .Ins(in_ins), .InsMemRW(InsMemRW)
    );

    // IR
    IR U_IR (
        .clk(clk), .IRWrite(IRWrite), .in_ins(in_ins), .out_ins(out_ins)
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
        .X(ALU_result_r), .Y(DR_out), .Z(PCA4), .control(WDSel), .out(WD)
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
        .X(RD1_r), .Y(32'h0), .control(ALUSrcA), .out(A)
    );

    // MUX_3to1_B
    MUX_3to1_B U_MUX_3to1_B (
        .X(RD2_r), .Y(Imm32), .Z(Offset), .control(ALUSrcB), .out(B)
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

    assign DR_out = RD;

endmodule
```

## 2-1 测试C程序,hex和tb

```c
#include <stdio.h>

int main()
{
    asm volatile("ori x23,x0 ,123 ");
    asm volatile("ori x24,x0 ,0x678 ");
    asm volatile("ori x1 ,x0 ,8 ");
    asm volatile("ori x2 ,x0 ,12 ");
    asm volatile("ori x3 ,x0 ,0 ");
    asm volatile("add x11,x2,x1 ");
    asm volatile("sub x12,x2,x1 ");
    asm volatile("addi x13,x2 ,1 "); // 
    asm volatile("or  x14,x2,x3 ");
    asm volatile("and x15,x1,x2 ");
    asm volatile("xor x19,x2,x1 ");
    asm volatile("ori x4 ,x0 ,4 ");
    asm volatile("sll x7 ,x2,x4 ");
    asm volatile("ori x15,x0 ,128 ");
    asm volatile("srl x6 ,x15,x4 ");
    asm volatile("sra x5 ,x15,x4 ");
    asm volatile("ori x4 ,x0 ,4 ");
    asm volatile("sw  x4 , -4(x1) ");
    asm volatile("sw  x2 , 0(x0) ");
    asm volatile("sw  x3 , 4(x0) ");
    asm volatile("lw  x5 , -8(x1) ");
    asm volatile("sll x5 ,x2 ,x4 ");
    asm volatile("_addi: ");
    asm volatile("addi x3 ,x2 ,1 ");
    asm volatile("or  x2 ,x3 ,x0 ");
    asm volatile("bne x3 ,x5 ,_addi ");
    asm volatile("addi x29,x0 ,76 ");
    asm volatile("addi x27,x0 ,0xab ");
    asm volatile("sw  x27,4(x29) ");
    asm volatile("jal x0 ,_jtest ");
    asm volatile("ori x0 ,x1 ,0 ");
    asm volatile("ori x0 ,x1 ,0 ");
    asm volatile("_jtest: ");
    asm volatile("lw  x28,4(x29) ");
}
```

```hex
07b06b93
67806c13
00806093
00c06113
00006193
001105b3
40110633
00110693
00316733
0020f7b3
001149b3
00406213
004113b3
08006793
0047d333
4047d2b3
00406213
fe40ae23
00202023
00302223
ff80a283
004112b3
00110193
0001e133
fe519ce3
04c00e93
0ab00d93
01bea223
0100006f
00000e13
00000e13
00000e13
004aea03
01cd8863
00000e13
00000e13
00000e13
004eaf03
```



```verilog
`timescale 1 ps / 1 ps

module riscv_sim ();

// Inputs
reg clk, rst;

riscv U_RISCV(
    .clk(clk), .rst(rst)
);

initial begin
    $readmemh ("../hex/code.hex", U_RISCV.U_IM.memory);
    $display("Instruction memory initialized");
    $monitor("PC = 0x%8X, IR = 0x%8X",U_RISCV.U_PC.PC, U_RISCV.out_ins );
    clk = 1 ;

    #5 ;
    rst = 1 ;
    #20 ;
    rst = 0 ;
end

always
    #(50) clk = ~clk;

initial begin
    $fsdbDumpvars(0,"riscv_sim");
    $fsdbDumpMDA(0,"riscv_sim");
end

endmodule
```







