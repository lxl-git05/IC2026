`timescale 1ns / 1ps

module cpu_add_tb;
    reg clk;
    reg rst;

    // 实例化CPU
    cpu_add cpu_add_inst(
        .clk(clk),
        .rst(rst)
    );

    // 时钟产生
    always #5 clk = ~clk;

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
