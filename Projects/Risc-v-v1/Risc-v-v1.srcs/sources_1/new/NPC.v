`include "Ctrl-signal-def.v"
`include "instruction-def.v"
module NPC(clk,rst,NPCOp,Offset12,Offset20,PC,rs,PCA4, NPC,rs_A);

    input clk,rst;
    input [1:0] NPCOp;
    input [11:0] Offset12;  // branch(需要左移) / jalr(不需要左移)
    input [20:1] Offset20;  // jal
    input [31:0] PC;
    input [31:0] rs;        // jalr使用: label = rs1 + imm
    input [31:0] rs_A ;     // MUX_2to1_A的数据冲突最新值,来自EX阶段的ALU结果,用于jalr指令的NPC计算
    output wire [31:0] PCA4;
    output reg [31:0] NPC;

    wire signed [31:0] Offset_B;      assign Offset_B = {{19{Offset12[11]}}, Offset12[11:0],1'b0};
    wire signed [31:0] Offset_JAL;    assign Offset_JAL = {{11{Offset20[20]}}, Offset20[20:1],1'b0};
    wire signed [31:0] offset_JalR;   assign offset_JalR = {{20{Offset12[11]}}, Offset12[11:0]} ;

    // 信号延迟
    // 进行PC延迟,从IF到EX,延迟2拍
    reg [31:0] PC_ID;
    reg [31:0] PC_EX;
    reg [31:0] Offset_B_EX;
    reg [31:0] Offset_JAL_EX;
    reg [31:0] offset_JalR_EX;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            PC_ID         <= 32'b0;
            PC_EX         <= 32'b0;
            Offset_B_EX   <= 32'b0;
            Offset_JAL_EX <= 32'b0;
            offset_JalR_EX<= 32'b0;
        end
        else begin
            // IF → ID
            PC_ID <= (PC === 32'bx) ? 32'b0 : PC;

            // ID → EX
            PC_EX <= PC_ID;

            // ID → EX (branch/jump offsets)
            Offset_B_EX    <= (Offset_B === 32'bx) ? 32'b0 : Offset_B;
            Offset_JAL_EX  <= (Offset_JAL === 32'bx) ? 32'b0 : Offset_JAL;
            offset_JalR_EX <= (offset_JalR === 32'bx) ? 32'b0 : offset_JalR;
        end
    end
    
    always@(*) begin
        case(NPCOp)
            `NPC_PC       : NPC = PC + 4;                                     // 正常执行需要直接输出当前IF的PC+4
            `NPC_Offset12 : NPC = PC_EX + Offset_B_EX ;                       // branch
            `NPC_rs       : NPC = (rs_A + offset_JalR_EX ) & 32'hffff_fffe;  // jalr                                           // jalr
            `NPC_Offset20 : NPC = PC_EX + Offset_JAL_EX ;                     // jal
            default       : NPC = PC + 4;
    endcase
        // PCA4 = PC_EX+4;  // 给jal和jalr使用的rd = PC + 4 存储
    end

    // 输出PCA4
    wire [31:0] PCA4_EX;  assign PCA4_EX = PC_EX + 4;
    reg  [31:0] PCA4_MEM;
    reg  [31:0] PCA4_WB;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            PCA4_MEM <= 32'b0;
            PCA4_WB  <= 32'b0;
        end
        else begin
            // EX → MEM（第1拍）
            PCA4_MEM <= PCA4_EX;
            // MEM → WB（第2拍）
            PCA4_WB  <= PCA4_MEM;
        end
    end

    assign PCA4 = PCA4_WB;

endmodule
