`include "Ctrl-signal-def.v"
module PC(clk,rst,PCWrite,NPC,PC,NPC_Enable);

    input clk;
    input rst;
    input PCWrite;
    input NPC_Enable;           // 新增: NPC_Enable 流水线中默认是PC+4,流水线中NPC_Enable为1时,PC为NPC
    input [31:0] NPC;
    output reg [31:0] PC;

    always @(posedge clk or posedge rst) begin
        // reset
        if (rst) begin
            // PC <= 32'h0000_2000;
            PC <= 32'hffff_fffc; // 修改复位地址为0xffff_fffc，确保PC+4后为0x0000_0000
        end
        else if (PCWrite) begin
            if (NPC_Enable) begin
                PC <= NPC;
            end
            else begin
                PC <= PC + 4;
            end
        end
    end

endmodule