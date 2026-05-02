`include "Ctrl-signal-def.v"
module MUX_2to1_A(X,Y,control,out);

    input [31:0] X;
    input [31:0] Y;
    input control;
    output [31:0] out;

    // 新增: 当control为0时,输出X的值(需要扩展成32位),当control为1时,输出Y的值
    assign out = (control == 1'b0 ? X : Y );

endmodule
