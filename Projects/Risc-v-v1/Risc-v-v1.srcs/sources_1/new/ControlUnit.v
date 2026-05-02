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
    output wire PCWrite,
    output wire InsMemRW,
    output wire IRWrite,
    output wire RFWrite,
    output wire DMCtrl,
    output wire ExtSel,
    output wire ALUSrcA,
    output wire [1:0] ALUSrcB,
    output wire [1:0] RegSel,
    output wire [1:0] NPCOp,
    output wire [1:0] WDSel,
    output reg [3:0] ALUOp
);

    // 先得到类型,好进行下面的分析 (暂时不支持U型指令)
    wire R_type;
    wire I_type;
    wire Load_type;
    wire Store_type;
    wire Branch_type;
    wire JAL_type;
    wire JALR_type;

    assign R_type      = (opcode == 7'b0110011);
    assign I_type      = (opcode == 7'b0010011);
    assign Load_type   = (opcode == 7'b0000011);
    assign Store_type  = (opcode == 7'b0100011);
    assign Branch_type = (opcode == 7'b1100011);
    assign JAL_type    = (opcode == 7'b1101111);
    assign JALR_type   = (opcode == 7'b1100111);
    
    // 单周期逻辑书写
    assign PCWrite  = 1'b1 ;    // PC每个周期都要更新
    assign InsMemRW = 1'b1 ;    // 每个周期都要读指令
    assign IRWrite  = 1'b1 ;    // 这个有锁存功能,暂时不使用

    assign RFWrite = R_type | I_type | Load_type | JAL_type | JALR_type;
    assign DMCtrl  = Store_type ;       // Store指令写内存,其他指令不写内存
    assign ExtSel =
        (I_type && (
            Funct3 == 3'b110 ||
            Funct3 == 3'b111 ||
            Funct3 == 3'b100 )) ? `ExtSel_ZERO : `ExtSel_SIGNED;
    assign ALUSrcA = `ALUSrcA_A ;         // JAL指令使用PC作为ALU的第一个操作数,其他指令使用Rs1(其实无所谓)
    assign ALUSrcB = 
        (R_type) ? `ALUSrcB_B : 
        (I_type | Load_type | JALR_type) ? `ALUSrcB_Imm : 
        (Store_type | JAL_type) ? `ALUSrcB_Offset : `ALUSrcB_else ;
    assign RegSel  = `RegSel_rd ;       // 默认使用rd作为目的寄存器,其他指令也无所谓
    assign NPCOp   = 
        (Branch_type && ((Funct3 == 3'b000 && zero) | (Funct3 == 3'b001 && !zero))) ? `NPC_Offset12 : 
        (JAL_type)    ? `NPC_Offset20 : 
        (JALR_type)   ? `NPC_rs : `NPC_PC ;
    assign WDSel = Load_type ? `WDSel_FromMEM : 
                   (JAL_type | JALR_type)  ? `WDSel_FromPC : `WDSel_FromALU ;

    // ALU控制信号
    always @(*)
    begin
        case(opcode)
            7'b0110011: // R-Type
            begin
                case(Funct3)
                    3'b000:
                    begin
                        if(Funct7 == 7'b0000000)
                            ALUOp = 4'b0000; // ADD
                        else if(Funct7 == 7'b0100000)
                            ALUOp = 4'b0001; // SUB
                    end
                    3'b111:
                        ALUOp = 4'b0010; // AND
                    3'b110:
                        ALUOp = 4'b0011; // OR
                    3'b100:
                        ALUOp = 4'b0100; // XOR
                    3'b001:
                        ALUOp = 4'b0101; // SLL
                    3'b101:
                    begin
                        if(Funct7 == 7'b0000000)
                            ALUOp = 4'b0110; // SRL
                        else if(Funct7 == 7'b0100000)
                            ALUOp = 4'b0111; // SRA
                    end
                    3'b010:
                        ALUOp = 4'b1000; // SLT
                    3'b011:
                        ALUOp = 4'b1001; // SLTU
                endcase
            end
            7'b0010011: // I-Type
            begin
                case(Funct3)
                    3'b000:
                        ALUOp = 4'b0000; // ADDI
                    3'b111:
                        ALUOp = 4'b0010; // ANDI
                    3'b110:
                        ALUOp = 4'b0011; // ORI
                    3'b100:
                        ALUOp = 4'b0100; // XORI
                endcase
            end
            7'b0000011: // Load
                ALUOp = 4'b0000;
            7'b0100011: // Store
                ALUOp = 4'b0000;
            7'b1100011: // Branch
                ALUOp = 4'b0001;
            7'b1100111: //JALR
                ALUOp = 4'b0000;// 执行加法 rs1 +imm
            default:
                ALUOp = 4'b0000;
        endcase
    end
endmodule