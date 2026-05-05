module Delay_tb;
    reg clk;
    reg rst;
    reg [31:0] in;
    reg [1:0] delay_num;
    wire [31:0] out;

    Delay  Delay_inst (
        .clk(clk),
        .rst(rst),
        .in(in),
        .delay_num(delay_num),
        .out(out)
    );

    always #5  clk = ! clk ;

    // 编写测试逻辑
    initial begin
        clk = 0;
        rst = 1;
        in = 0;
        delay_num = 2'b00;

        #6;
        rst = 0;
        // 先测试延迟1个周期
        in = 32'h0000_0001;
        delay_num = 2'b01;  // 延迟1周期
        #10;
        in = 32'h0000_0002;
        #10;
        in = 32'h0000_0003;
        #10;
        // 再测试延迟2个周期
        in = 32'h0000_0004;
        delay_num = 2'b10;  // 延迟2周期
        #10;
        in = 32'h0000_0005; 
        #10;
        in = 32'h0000_0006;
        #10;
        in = 32'h0000_0007;
        #10;
        // 再测试延迟3个周期
        in = 32'h0000_0008;
        delay_num = 2'b11;  // 延迟3周期
        #10;
        in = 32'h0000_0009;
        #10;
        in = 32'h0000_000A;
        #10;
        in = 32'h0000_000B;
        #10;
        in = 32'h0000_000C;
        #10;
        in = 32'h0000_000D;
        #10;
        in = 32'h0000_000E;
        #10;
        in = 32'h0000_000F;
        #10;
        $finish;
    end



endmodule