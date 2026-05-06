// module Delay #(
//     parameter WIDTH = 32
// )(
//     input clk,
//     input rst,
//     input [WIDTH-1:0] in,
//     input [1:0] delay_num,
//     output reg [WIDTH-1:0] out
// );

// reg [WIDTH-1:0] stage1;
// reg [WIDTH-1:0] stage2;
// reg [WIDTH-1:0] stage3;

// initial begin
//     stage1 = {WIDTH{1'b0}};
//     stage2 = {WIDTH{1'b0}};
//     stage3 = {WIDTH{1'b0}};
// end

// always @(posedge clk or posedge rst) begin
//     if(rst) begin
//         stage1 <= {WIDTH{1'b0}};
//         stage2 <= {WIDTH{1'b0}};
//         stage3 <= {WIDTH{1'b0}};
//     end
//     else begin
//         // 如果输入全X，则置0
//         stage1 <= (in === {WIDTH{1'bx}}) ? {WIDTH{1'b0}} : in;
//         stage2 <= stage1;
//         stage3 <= stage2;
//     end
// end

// always @(*) begin
//     case(delay_num)
//         2'b00: out = in;
//         2'b01: out = stage1;
//         2'b10: out = stage2;
//         2'b11: out = stage3;
//         default: out = {WIDTH{1'b0}};
//     endcase
// end

// endmodule