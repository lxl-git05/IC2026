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
    reg [31:0] ALU_result_r_delay_1;
    reg [31:0] Y_delay;
    reg [11:0] Z_delay;
    always @(posedge clk) begin
        ALU_result_r_delay_1  <= (ALU_result_r === 32'bx) ? 32'b0 : ALU_result_r;
        Y_delay               <= (Y === 32'bx) ? 32'b0 : Y;
        Z_delay               <= (Z === 12'bx) ? 12'b0 : Z;
    end
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