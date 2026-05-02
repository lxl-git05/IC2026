`include "Ctrl-signal-def.v"
`include "instruction-def.v"
module NPC(NPCOp,Offset12,Offset20,PC,rs,PCA4, NPC);

    input [1:0] NPCOp;
    input [12:1] Offset12;  // branch
    input [20:1] Offset20;  // jal
    input [31:0] PC;
    input [31:0] rs;        // jalr使用: label = rs1 + imm
    output reg [31:0] PCA4;
    output reg [31:0] NPC;

    wire signed [12:0] Offset13;
    wire signed [20:0] Offset21;

    assign Offset13 = $signed({Offset12[12:1],1'b0});
    assign Offset21 = $signed({Offset20[20:1],1'b0});

    always@(*) begin
        case(NPCOp)
            `NPC_PC       : NPC = PC + 4;                                       // 正常执行
            `NPC_Offset12 : NPC = PC + Offset13 ;   // branch
            `NPC_rs       : NPC = (rs + {{20{Offset12[12]}}, Offset12[12:1]}) & 32'hffff_fffe; // jalr                                           // jalr
            `NPC_Offset20 : NPC = PC + Offset21 ;   // jal
        endcase
        PCA4 = PC+4;  // 给jal和jalr使用的rd = PC + 4 存储
    end

endmodule
