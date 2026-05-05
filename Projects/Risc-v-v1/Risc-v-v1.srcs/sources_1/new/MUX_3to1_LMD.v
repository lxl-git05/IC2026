`include "Ctrl-signal-def.v"
module MUX_3to1_LMD(clk,X,Y,Z,control,out);
    input clk;
    input [31:0] X;
    input [31:0] Y;
    input [31:2] Z;
    input [1:0] control;
    output reg[31:0] out;

    // ALU计算结果打拍延迟
    wire [31:0] X_delay;
    Delay #(32) Delay_inst (
        .clk(clk),
        .rst(1'b0),
        .in(X),
        .delay_num(2'b01),  // 1周期延迟
        .out(X_delay)
    );

    always @ (X or Y or Z or control) begin
        case(control)
            `WDSel_FromALU : out = X_delay;
            `WDSel_FromMEM : out = Y;
            `WDSel_FromPC  : out = Z;
            `WDSel_Else    : out = 0;
        endcase
    end

endmodule
