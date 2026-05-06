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
    wire [31:0] PC_ID;
    wire [31:0] PC_EX;
    wire [31:0] Offset_B_EX;       // 来自ID
    wire [31:0] Offset_JAL_EX;     // 来自ID
    wire [31:0] offset_JalR_EX;    // 来自ID

    // 进行PC延迟,从IF到EX,延迟2拍
    Delay #(32) Delay_PC_inst_1 (
        .clk(clk),
        .rst(rst),
        .in(PC),
        .delay_num(2'b01),  // 1周期延迟
        .out(PC_ID)
    );
    Delay #(32) Delay_PC_inst_2 (
        .clk(clk),
        .rst(rst),
        .in(PC_ID),
        .delay_num(2'b01),  // 1周期延迟
        .out(PC_EX)
    );
    // 进行offset延迟
    Delay #(32) Delay_Offset_B_inst (
        .clk(clk),
        .rst(rst),
        .in(Offset_B),
        .delay_num(2'b01),  // 1周期延迟
        .out(Offset_B_EX)
    );
    Delay #(32) Delay_Offset_JAL_inst (
        .clk(clk),
        .rst(rst),
        .in(Offset_JAL),
        .delay_num(2'b01),  // 1周期延迟
        .out(Offset_JAL_EX)
    );
    Delay #(32) Delay_offset_JalR_inst (
        .clk(clk),
        .rst(rst),
        .in(offset_JalR),
        .delay_num(2'b01),  // 1周期延迟
        .out(offset_JalR_EX)
    );
    
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

    wire [31:0] PCA4_EX;
    assign PCA4_EX = PC_EX + 4;

    // 发送PCA4需要延迟两拍到WB阶段
    Delay #(32) Delay_PCA4_inst (
        .clk(clk),
        .rst(rst),
        .in(PCA4_EX),
        .delay_num(2'b10),  // 2周期延迟
        .out(PCA4)
    );

endmodule
