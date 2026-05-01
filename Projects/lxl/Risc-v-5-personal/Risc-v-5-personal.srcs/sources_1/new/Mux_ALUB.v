// ALUB的选择器
module Mux_ALUB(
        input wire [31:0] data2,    // 00
        input wire [31:0] imme,     // 01
        input  [1: 0] ALUBsrc,
        output [31:0] ALUB_out 
    );
    assign ALUB_out = ALUBsrc == 2'b00 ? data2 : 
                      ALUBsrc == 2'b01 ? imme  : 32'd4 ;
endmodule
