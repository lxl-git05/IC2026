`include "Ctrl-signal-def.v"
module MUX_3to1_B(clk,X,Y,Z,ALU_result_r,control,out);
    input clk;          // 新增: 时钟
    input  wire [31:0] X;
    input  wire [31:0] Y;
    input  wire [11:0] Z;
    input  wire [31:0] ALU_result_r;  // 新增: ALU_result_r输入
    input  wire [2:0] control;
    output reg signed [31:0] out;

    // 新增: Y,Z,ALU_result 延迟1拍
    wire [31:0] Y_delay;
    wire [11:0] Z_delay;
    wire [31:0] ALU_result_r_delay_1;
    Delay  #(32)Delay_inst_ALU_result_1 (
        .clk(clk),
        .rst(1'b0),
        .in(ALU_result_r),
        .delay_num(2'b01),  // 1周期延迟
        .out(ALU_result_r_delay_1)
    );
    Delay  #(32)Delay_inst_Y (
        .clk(clk),
        .rst(1'b0),
        .in(Y),
        .delay_num(2'b01),  // 1周期延迟
        .out(Y_delay)
    );
    Delay  #(12)Delay_inst_Z (
        .clk(clk),
        .rst(1'b0),
        .in(Z),
        .delay_num(2'b01),  // 1周期延迟
        .out(Z_delay)
    );
    // 输出结果
    always @ (*) begin
        case(control)
            3'b000 : out = X;  // 事先输入的时候就延迟了1拍,所以这里不需要延迟
            3'b001 : out = Y_delay;
            3'b010 : out = $signed(Z_delay);
            3'b011 : out = ALU_result_r;
            3'b100 : out = ALU_result_r_delay_1;
            default: out = X;
        endcase
    end
endmodule