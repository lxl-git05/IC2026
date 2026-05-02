`include "Ctrl-signal-def.v"
module DM( Addr, WD, clk, DMCtrl, RD);

    input [11:2] Addr;
    input [31:0] WD;
    input clk;
    input DMCtrl;      // 1: Write, 0: Read
    output [31:0] RD;  // 去掉 reg，改为 wire 类型的异步输出

    reg [31:0] memory[0:1023];

    // 新增:初始化:直接进行内存清零，避免仅读取垃圾数据,后续需要删除,因为比赛测试不需要内存初始化
    integer i;
    initial begin
        for (i = 0; i < 1024; i = i + 1) memory[i] = 0;
    end

    // 同步写：必须在时钟上升沿触发
    always @(posedge clk) begin
        if (DMCtrl == 1'b1) begin // 建议使用宏定义增加可读性,1'b1
            memory[Addr] <= WD;
        end
    end

    // 新增:异步读：直接根据地址输出数据 (单周期 CPU 的标准做法)
    assign RD = memory[Addr];

endmodule