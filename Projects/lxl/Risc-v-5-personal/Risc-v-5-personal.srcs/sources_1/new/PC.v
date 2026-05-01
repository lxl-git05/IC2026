module PC(
        input  wire clk,
        input  wire rst,
        input  wire[31:0] PC_new,
        output reg [31:0] PC_out
    );
    // 优化:
    // 添加addr初始化,原因:最最最开始时,addr是X,算作状态1
    // 那么当addr在初始rst=1的时候,又会变成0,导致addr状态产生一次变化
    initial PC_out = 32'd0;
    // 书写逻辑
    always @(posedge clk or posedge rst)
    begin
        if (rst)    PC_out <= 32'd0  ;
        else        PC_out <= PC_new ;
    end

endmodule
