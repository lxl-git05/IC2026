`include "Ctrl-signal-def.v"
module MUX_2to1_A(clk,X,Y,ALU_result_r,control,out);
    input clk;
    input [31:0] X;
    input [31:0] Y;
    input [31:0] ALU_result_r; // 新增: ALU_result_r输入
    input [1:0]control;
    output [31:0] out;

    // 先进行delay
    wire [31:0] ALU_result_r_delay_1;  // 延迟1拍
    Delay #(32) Delay_inst_1 (
        .clk(clk),
        .rst(1'b0),
        .in(ALU_result_r),
        .delay_num(2'b01),  // 1周期延迟
        .out(ALU_result_r_delay_1)
    );

    // 新增: 当control为0时,输出X的值(需要扩展成32位),当control为1时,输出Y的值
    // 新增: 数据前递(control位宽增加)
    assign out = control == 2'b00 ? X : (control == 2'b01 ? Y : (control == 2'b10 ? ALU_result_r : ALU_result_r_delay_1));

endmodule
