`timescale 1ns / 1ps

module Instr_mem_tb;

    reg  [31:0] addr;
    wire [31:0] instr;

    // DUT
    Instr_mem Instr_mem_inst (
        .addr(addr),
        .instr(instr)
    );

    initial begin
        // 初始化
        addr = 32'd0;
        
        #10;
        $display("addr=%d instr=%h", addr, instr);  // 查看参数

        // 下一条指令
        addr = 32'd4;
        #10;
        $display("addr=%d instr=%h", addr, instr);

        // 下一条指令
        addr = 32'd8;
        #10;
        $display("addr=%d instr=%h", addr, instr);

        addr = 32'd12;
        #10;
        $display("addr=%d instr=%h", addr, instr);

        addr = 32'd16;
        #10;
        $display("addr=%d instr=%h", addr, instr);

        addr = 32'd20;
        #10;
        $display("addr=%d instr=%h", addr, instr);

        addr = 32'd24;
        #10;
        $display("addr=%d instr=%h", addr, instr);

        addr = 32'd28;
        #10;
        $display("addr=%d instr=%h", addr, instr);

        addr = 32'd32;
        #10;
        $display("addr=%d instr=%h", addr, instr);

        addr = 32'd36;
        #10;
        $display("addr=%d instr=%h", addr, instr);

        #10 $finish;
    end

endmodule
