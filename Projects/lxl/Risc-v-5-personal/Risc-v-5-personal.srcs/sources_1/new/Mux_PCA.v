// Mux_PCA 的选择器
module Mux_PCA(
        input wire [31:0] imme,    // 1
        input PCAsrc,
        output [31:0] PCA_out 
    );
    assign PCA_out = (PCAsrc == 1'b0 ? 32'd4 : imme);
endmodule
