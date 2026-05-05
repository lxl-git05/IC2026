module RF_tb;
    reg [4:0] RR1;
    reg [4:0] RR2;
    reg [4:0] WR;
    reg [31:0] WD;
    reg RFWrite;
    reg clk;
    wire [31:0] RD1;
    wire [31:0] RD2;

    RF  RF_inst (
        .RR1(RR1),
        .RR2(RR2),
        .WR(WR),
        .WD(WD),
        .RFWrite(RFWrite),
        .clk(clk),
        .RD1(RD1),
        .RD2(RD2)
    );

    always #5  clk = ! clk ;

    initial begin
        clk = 0;
        RR1 = 0;
        RR2 = 0;
        WR = 0;
        WD = 0;
        RFWrite = 0;
        // 读寄存器测试
        #10; RR1 = 5'd2; RR2 = 5'd3; 
        #10; RR1 = 5'd5; RR2 = 5'd6; 
        #10; RR1 = 5'd8; RR2 = 5'd9; 
        // 写寄存器测试
        #10; WR = 5'd1; WD = 32'h0000_0001; RFWrite = 1; 
        #10; WR = 5'd2; WD = 32'h0000_0002; RFWrite = 1; 
        #10; WR = 5'd3; WD = 32'h0000_0003; RFWrite = 1; 
        #10; WR = 5'd4; WD = 32'h0000_0004; RFWrite = 1; 
        $finish;
    end

endmodule
