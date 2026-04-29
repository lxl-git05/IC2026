// 寄存器:作为rs1,rs2,rd的工作器
// 例:rd = rs1 + rs2 -> rs1和rs2作为地址查询具体值,然后去到ALU进行计算,然后得到wr_data
// 写回rd对于的寄存器,实现寄存器操作(本操作使用到了rd,所以需要使能wr_en)
module Rigister(
        input clk ,     
        input wr_en,            // 使能写入rd  
  
        input  [4:0] rs1,       // rs1的地址
        input  [4:0] rs2,       // rs2的地址
        input  [4:0] rd,

        input  [31:0] wr_data,  // 写入rd的值

        output [31:0] data1,    // rs1的数据
        output [31:0] data2     // rs2的数据
    );

    // 定义32个系统寄存器,都是32位
    reg [31:0] register[0:31] ;
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

    // 书写逻辑
    // 1. 得到相关数据输出
    assign data1 = register[rs1];
    assign data2 = register[rs2];
    // 2. 数据写回判断
    always @(posedge clk) 
    begin
        if (wr_en == 1'b1) 
        begin
            if (rd != 5'd0)     // x0不可写
            begin
                register[rd] <=  wr_data ;
            end
        end
    end
endmodule
