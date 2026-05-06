`include "Ctrl-signal-def.v"
module IR(in_ins, clk, IRWrite, out_ins,flush);

    input clk, IRWrite, flush;
    input [31:0] in_ins;
    output reg[31:0] out_ins;
    
    always @(posedge clk) begin
        if (IRWrite) begin
            if (flush) begin
                out_ins <= 32'h00000013; // 冲刷指令,注入NOP
            end else begin
                out_ins <= in_ins;
            end
        end
    end

endmodule
