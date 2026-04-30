
module cpu_I_Type_tb;
  reg  clk;
  reg  rst;

  cpu_I_Type  cpu_I_Type_inst (
    .clk(clk),
    .rst(rst)
  );

    always #5  clk = ! clk ;
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