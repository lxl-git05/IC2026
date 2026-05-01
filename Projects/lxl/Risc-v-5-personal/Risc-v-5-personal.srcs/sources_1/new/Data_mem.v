module Data_mem(
    input wire clk,
    input wire rst,

    input wire W_en,
    input wire R_en,

    input wire [31:0] addr,
    input wire [2:0] RW_Type,   // 暂时用不上(sw,lw够用了)
    input wire [31:0] din,

    output reg [31:0] dout
);

    reg [31:0] ram[0:255];
    integer i;

    // 同步写
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            for(i=0;i<256;i=i+1)
                ram[i] <= 32'b0;
        end
        else if(W_en) begin
            ram[addr[9:2]] <= din; // ram_index = addr / 4
        end
    end

    // 异步读
    always @(*) begin
        if(R_en)
            dout = ram[addr[9:2]];
        else
            dout = 32'b0;
    end

endmodule
