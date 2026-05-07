`include "Ctrl-signal-def.v"
`include "instruction-def.v"
module RF(
    input  [4:0] RR1,
    input  [4:0] RR2,
    input  [4:0] WR,
    input  [31:0] WD,
    input RFWrite,
    input clk,
    output [31:0] RD1,
    output [31:0] RD2
);

    reg [31:0] register [0:31];

    // WR打拍延迟
    reg [4:0] WR_d1;
    reg [4:0] WR_d2;
    reg [4:0] WR_delay;

    always @(posedge clk) begin
        // stage1
        WR_d1 <= (WR === 5'bx) ? 5'b0 : WR;
        // stage2
        WR_d2 <= WR_d1;
        // stage3
        WR_delay <= WR_d2;
    end

    // write
    always @(negedge clk) begin
        if (RFWrite && (WR_delay != 0))   // 不准修改x0
            register[WR_delay] <= WD;
    end

    // read（组合逻辑）
    assign RD1 = (RR1 === 0) ? 32'b0 : register[RR1];    // x0就是0
    assign RD2 = (RR2 === 0) ? 32'b0 : register[RR2];

endmodule
