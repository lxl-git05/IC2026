`include "Ctrl-signal-def.v"
module IM(InsMemRW, addr,Ins);

    input InsMemRW;
    input [11:2] addr;
    output reg [31:0] Ins;
    reg [31:0] memory[0:1023];

    always @(addr or InsMemRW) begin
        if (InsMemRW) begin
            Ins = memory[addr]; // 读取指令,这里从<=修改为=,因为IM是组合逻辑电路,不需要时序逻辑的非阻塞赋值
        end
    end

endmodule
