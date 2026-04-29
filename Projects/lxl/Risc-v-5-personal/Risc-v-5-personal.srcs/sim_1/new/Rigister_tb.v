module Rigister_tb;

    reg clk;
    reg wr_en;
    reg  [4:0]  rs1;
    reg  [4:0]  rs2;
    reg  [4:0]  rd;
    reg  [31:0] wr_data;
    wire [31:0] data1;
    wire [31:0] data2;

    Rigister  Rigister_inst (
        .clk(clk),
        .wr_en(wr_en),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .wr_data(wr_data),
        .data1(data1),
        .data2(data2)
    );
  
    // 逻辑书写
    // 1. 时钟
    always #5  clk = ! clk ;    

    // 2. 主体逻辑
    initial
    begin
        clk = 0;
        wr_en = 0;
        rs1 = 0;
        rs2 = 0;
        rd = 0;
        wr_data = 0;

        // 等待
        #10;

        // 写x1 = 100
        wr_en = 1;
        rd = 5'd1;
        wr_data = 32'd100;
        #10;

        // 写x2 = 200
        rd = 5'd2;
        wr_data = 32'd200;
        #10;

        // 读x1,x2
        wr_en = 0;
        rs1 = 5'd1;
        rs2 = 5'd2;
        #10;

        // 尝试写x0（应该失败）
        wr_en = 1;
        rd = 5'd0;
        wr_data = 32'd999;
        #10;

        // 读x0
        wr_en = 0;
        rs1 = 5'd0;
        #10;

        $stop;
    end

endmodule
