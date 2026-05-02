`include "Ctrl-signal-def.v"
module DM( Addr,WD,clk,DMCtrl,RD);  // 外设: 内存

    input [11:2] Addr;
    input [31:0] WD;
    input clk;
    input DMCtrl;
    output reg [31:0] RD;

    reg [31:0] memory[0:1023];

    always @(posedge clk) begin
        if (DMCtrl) begin
            memory[Addr] <= WD;
        end
        else begin
            RD <= memory[Addr];
        end
    end // end always

endmodule
