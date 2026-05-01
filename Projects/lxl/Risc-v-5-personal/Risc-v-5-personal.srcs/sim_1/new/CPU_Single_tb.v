`timescale 1ns/1ps

module CPU_Single_tb;

    reg clk;
    reg rst;

    // 实例化 CPU
    CPU_Single uut(
        .clk(clk),
        .rst(rst)
    );

    // clock
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;

        #20;
        rst = 0;
    end

    // 仿真激励
    initial begin
        // 初始化
        clk = 0;
        rst = 1;

        // 保持复位一段时间
        #20;

        // 释放复位
        rst = 0;

        // 跑10个周期
        #100;

        // 停止仿真
        $finish;
    end

endmodule
