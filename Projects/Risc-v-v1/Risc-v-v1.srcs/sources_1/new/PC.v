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
            // PC <= 32'h0000_2000;
            PC <= 32'hffff_fffc; // 修改复位地址为0xffff_fffc，确保PC+4后为0x0000_0000
        end
        else if (PCWrite) begin
            PC <= NPC;
        end
    end

endmodule