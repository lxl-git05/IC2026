`timescale 1ns / 1ps
module DM_tb();

    // 信号定义
    reg [11:2] Addr;
    reg [31:0] WD;
    reg clk;
    reg DMCtrl;
    wire [31:0] RD;

    // 实例化被测模块 (DUT)
    DM uut (
        .Addr(Addr), 
        .WD(WD), 
        .clk(clk), 
        .DMCtrl(DMCtrl), 
        .RD(RD)
    );

    // 时钟生成：周期为 10ns (100MHz)
    initial clk = 0;
    always #5 clk = ~clk;

    // 测试
    initial begin
        // 测试地址0x00000010的读写
        #10;
        DMCtrl = 1;
        Addr = 32'h00000010;
        WD = 32'h12345678;

        #10;    // 20
        DMCtrl = 0;

        #10;    // 30
        Addr = 32'h00000010;
        
        // 测试地址0x00000020的读写
        #10;    // 40
        DMCtrl = 1;
        Addr = 32'h00000020;
        WD = 32'h87654321;

        #10;    // 50
        DMCtrl = 0;

        #10;    // 60
        Addr = 32'h00000020;

        // 测试地址0x00000000的非法读写
        #10;    // 70
        DMCtrl = 0; // 只读,预期WD不被写入,输出RD为原值
        Addr = 32'h00000000;
        WD = 32'h66666666;

        #10;    // 80
        DMCtrl = 1; // 证明无论如何RD都不被写入,输出RD为Addr指示的值

        #10;    // 90
        Addr = 32'h00000000;
        #10;    // 100
        Addr = 32'h00000010;
    end

endmodule
