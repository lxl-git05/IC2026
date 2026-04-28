module PC(
        input  wire clk,
        input  wire rst,
        output reg [31:0] addr
    );
    // 书写逻辑
    always @(posedge clk or posedge rst)
    begin
        if (rst)    addr <= 32'd0 ;
        else        addr <= addr + 32'd4 ;
    end

endmodule
