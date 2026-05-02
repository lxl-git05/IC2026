`include "Ctrl-signal-def.v"
module MUX_3to1_LMD(X,Y,Z,control,out);

    input [31:0] X;
    input [31:0] Y;
    input [31:2] Z;
    input [1:0] control;
    output reg[31:0] out;

    always @ (X or Y or Z or control) begin
        case(control)
            `WDSel_FromALU : out = X;
            `WDSel_FromMEM : out = Y;
            `WDSel_FromPC  : out = Z;
            `WDSel_Else    : out = 0;
        endcase
    end

endmodule
