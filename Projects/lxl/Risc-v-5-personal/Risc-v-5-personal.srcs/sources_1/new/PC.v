module PC(
        input  wire clk,
        input  wire rst,
        output reg [31:0] addr
    );
    // 优化:
    // 添加addr初始化,原因:最最最开始时,addr是X,算作状态1
    // 那么当addr在初始rst=1的时候,又会变成0,导致addr状态产生一次变化
    initial addr = 32'd0;
    // 书写逻辑
    always @(posedge clk or posedge rst)
    begin
        if (rst)    addr <= 32'd0 ;
        else        addr <= addr + 32'd4 ;
    end

endmodule
