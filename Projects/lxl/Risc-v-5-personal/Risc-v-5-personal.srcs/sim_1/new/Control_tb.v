`timescale 1ns/1ps

module Control_tb;

reg [6:0] op;
reg [2:0] func3;
reg [6:0] func7;

wire [2:0] ExtOp;
wire RegWr;
wire ALUAsrc;
wire [1:0] ALUBsrc;
wire [3:0] Alu_ctrl;
wire [2:0] Branch;
wire MemtoReg;
wire MemW_en;
wire MemR_en;


Control uut(
    .op(op),
    .func3(func3),
    .func7(func7),

    .ExtOp(ExtOp),
    .RegWr(RegWr),
    .ALUAsrc(ALUAsrc),
    .ALUBsrc(ALUBsrc),
    .Alu_ctrl(Alu_ctrl),
    .Branch(Branch),
    .MemtoReg(MemtoReg),
    .MemW_en(MemW_en),
    .MemR_en(MemR_en)
);

initial begin

    //---------------------------------
    // add
    //---------------------------------
    op    = 7'b0110011;
    func3 = 3'b000;
    func7 = 7'b0000000;
    #10;

    //---------------------------------
    // addi
    //---------------------------------
    op    = 7'b0010011;
    func3 = 3'b000;
    func7 = 7'b0000000;
    #10;

    //---------------------------------
    // lw
    //---------------------------------
    op    = 7'b0000011;
    func3 = 3'b010;
    func7 = 7'b0000000;
    #10;

    //---------------------------------
    // sw
    //---------------------------------
    op    = 7'b0100011;
    func3 = 3'b010;
    func7 = 7'b0000000;
    #10;

    //---------------------------------
    // beq
    //---------------------------------
    op    = 7'b1100011;
    func3 = 3'b000;
    func7 = 7'b0000000;
    #10;

    //---------------------------------
    // bne
    //---------------------------------
    op    = 7'b1100011;
    func3 = 3'b001;
    func7 = 7'b0000000;
    #10;

    //---------------------------------
    // jal
    //---------------------------------
    op    = 7'b1101111;
    func3 = 3'b000;
    func7 = 7'b0000000;
    #10;

    //---------------------------------
    // jalr
    //---------------------------------
    op    = 7'b1100111;
    func3 = 3'b000;
    func7 = 7'b0000000;
    #10;

    $stop;
end

endmodule
