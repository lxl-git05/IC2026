`timescale 1ns/1ps

module Data_mem_tb;

    reg clk;
    reg rst;

    reg W_en;
    reg R_en;

    reg [31:0] addr;
    reg [2:0]  RW_Type;
    reg [31:0] din;

    wire [31:0] dout;

    // 实例化 Data_mem
    Data_mem uut (
        .clk(clk),
        .rst(rst),
        .W_en(W_en),
        .R_en(R_en),
        .addr(addr),
        .RW_Type(RW_Type),
        .din(din),
        .dout(dout)
    );

    // 时钟：10ns周期
    always #5 clk = ~clk;

    initial begin
        // 初始化
        clk     = 0;
        rst     = 1;
        W_en    = 0;
        R_en    = 0;
        addr    = 0;
        RW_Type = 3'b010;   // 010表示word
        din     = 0;

        // 保持复位
        #20;
        rst = 0;

        // ==========================
        // 测试 sw
        // sw x?, 0x10
        // ==========================
        #10;
        W_en = 1;
        addr = 32'h00000010;
        din  = 32'h12345678;

        #10;
        W_en = 0;

        // ==========================
        // 测试 lw
        // lw x?, 0x10
        // ==========================
        #10;
        R_en = 1;
        addr = 32'h00000010;

        #10;

        // 检查结果
        if(dout == 32'h12345678)
            $display("PASS: lw/sw success, dout = %h", dout);
        else
            $display("FAIL: dout = %h", dout);

        R_en = 0;

        // ==========================
        // 再测另一地址
        // ==========================
        #10;
        W_en = 1;
        addr = 32'h00000020;
        din  = 32'hAAAAAAAA;

        #10;
        W_en = 0;

        #10;
        R_en = 1;
        addr = 32'h00000020;

        #10;

        if(dout == 32'hAAAAAAAA)
            $display("PASS: second test success, dout = %h", dout);
        else
            $display("FAIL: dout = %h", dout);

        #20;
        $stop;
    end

endmodule
