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

    // write
    always @(posedge clk) begin
        if (RFWrite && (WR != 0))   // 不准修改x0
            register[WR] <= WD;
    end

    // read（组合逻辑）
    assign RD1 = (RR1 == 0) ? 32'b0 : register[RR1];    // x0就是0
    assign RD2 = (RR2 == 0) ? 32'b0 : register[RR2];

endmodule