// Mux_PCB 的选择器
module Mux_PCB(
        input wire [31:0] PC ,    // 0
        input wire [31:0] rs1,    // 1
        input PCBsrc,
        output [31:0] PCB_out 
    );
    assign PCB_out = (PCBsrc == 1'b0 ? PC : rs1);
endmodule
