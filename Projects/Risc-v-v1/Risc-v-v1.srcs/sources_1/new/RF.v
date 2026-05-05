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

    integer i;
    // 初始化寄存器
    initial begin
        // 全部清零
        for(i = 0; i < 32; i = i + 1)
            register[i] = 32'd0;

        // DEBUG使用
        // 给测试数据
        register[2] = 32'd10;
        register[3] = 32'd20;

        register[5] = 32'd30;
        register[6] = 32'd40;

        register[8] = 32'd50;
        register[9] = 32'd60;
    end

    // WR打拍延迟
    wire [4:0] WR_delay;
    Delay #(5) Delay_inst (
        .clk(clk),
        .rst(rst),
        .in(WR),
        .delay_num(2'b11),  // 3周期延迟
        .out(WR_delay)
    );

    // write
    always @(negedge clk) begin
        if (RFWrite && (WR_delay != 0))   // 不准修改x0
            register[WR_delay] <= WD;
    end

    // read（组合逻辑）
    assign RD1 = (RR1 === 0) ? 32'b0 : register[RR1];    // x0就是0
    assign RD2 = (RR2 === 0) ? 32'b0 : register[RR2];

endmodule
