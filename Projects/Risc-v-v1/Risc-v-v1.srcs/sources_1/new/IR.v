`include "Ctrl-signal-def.v"
module IR(in_ins, clk, IRWrite, PC_in , out_ins , PC_out);

    input clk, IRWrite;
    input [31:0] in_ins;
    input [31:0] PC_in;         // 新增PC输入
    output reg[31:0] out_ins;
    output reg[31:0] PC_out;    // 新增增PC输出
    
    always @(posedge clk) begin
        if (IRWrite) begin
            out_ins <= in_ins;
            PC_out <= PC_in;
        end
    end

endmodule
