`include "Ctrl-signal-def.v"
`include "instruction-def.v"
module RF(
    input [4:0] RR1,
    input [4:0] RR2,
    input [4:0] WR,
    input [31:0] WD,
    input RFWrite,
    input clk,
    output [31:0] RD1,
    output [31:0] RD2
);

    reg [31:0] register [0:31];

    always @(clk) begin
        register[0] = 32'h0;
    end

    always @(posedge clk) begin
        if ((WR != 0) && (RFWrite == 1)) begin
            register[WR] <= WD;
        end
    end

    assign RD1 = register[RR1];
    assign RD2 = register[RR2];

endmodule