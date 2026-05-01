// ALUA的选择器
module Mux_ALUA(
        input wire [31:0] data1,    // 0
        input wire [31:0] PC,       // 1
        input ALUAsrc,
        output [31:0] ALUA_out 
    );
    assign ALUA_out = (ALUAsrc == 1'b0 ? data1 : PC);
endmodule
