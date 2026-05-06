`include "Ctrl-signal-def.v"
module MUX_3to1_LMD(clk,X,Y,Z,control,out);
    input clk;
    input [31:0] X;
    input [31:0] Y;
    input [31:0] Z;
    input [1:0] control;
    output reg[31:0] out;

    // ALU计算结果打拍延迟
    reg [31:0] X_delay;
    always @(posedge clk) begin
        X_delay <= (X === 32'bx) ? 32'b0 : X;
    end

    always @ (X or Y or Z or control) begin
        case(control)
            `WDSel_FromALU : out = X_delay;
            `WDSel_FromMEM : out = Y;
            `WDSel_FromPC  : out = Z << 2;  // PCA4存储的是PC+4的值, 需要左移2位才能得到正确的地址
            `WDSel_Else    : out = 0;
        endcase
    end

endmodule
