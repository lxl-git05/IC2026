// 单周期CPU,实现所有赛题要求的指令
module CPU_Single(
        input clk,
        input rst
    );

    // 指令系列信号
    wire [31:0] PC_new;
    wire [31:0] PC_out;
    wire [31:0] instr;

    // 解码的信号
    wire [ 6: 0] func7 ;
    wire [ 4: 0]   rs2 ;
    wire [ 4: 0]   rs1 ;
    wire [ 2: 0] func3 ;
    wire [ 4: 0]    rd ;
    wire [ 6: 0]    op ;
    wire [31: 0]   imm ;    // 其实就是instr,这里要注意一下,后续再改进

    // 寄存器相关参数
    wire [31:0] Mem2Reg_out ;   // 写回的数据(经过了mux)
    wire [31:0] data1;          // rs1代表的数据
    wire [31:0] data2;          // rs2代表的数据

    // 控制台相关信号
    wire [2:0] ExtOp ;        // imm扩展类型信号
    wire RegWr ;              // 寄存器写入使能
    wire ALUAsrc;             // Rs1的选择器
    wire [1:0]ALUBsrc;        // Rs2的选择器
    wire [3:0] Alu_ctrl;      // ALU的控制信号
    wire [2:0] Branch;        // B型信号的Mux
    wire MemtoReg;            // 回写的Mux选择
    wire MemW_en;             // 内存写入使能
    wire MemR_en;             // 内存读取使能

    // imm拓展信号
    wire [31: 0]   imme ;     // imm拓展信号

    // Mux和Branch
    wire PCAsrc ;
    wire PCBsrc ;
    wire [31:0] PCA_out ;
    wire [31:0] PCB_out ;
    wire [31:0] ALUA_out;
    wire [31:0] ALUB_out;
    // ALu
    wire Zero ;
    wire [31:0] ALU_out ;
    wire [31:0] Mem_Data_out ;

    // 1. PC模块
    PC  PC_inst (
        .clk(clk),
        .rst(rst),
        .PC_new(PC_new),
        .PC_out(PC_out)
    );
    // 2. 取指令
    Instr_mem  Instr_mem_inst (
        .addr(PC_out),
        .instr(instr)
    );
    // 3. 解码Decoder
    Decode  Decode_inst (
        .instr(instr),
        .func7(func7),
        .rs2(rs2),
        .rs1(rs1),
        .func3(func3),
        .rd(rd),
        .op(op),
        .imm(imm)
    );
    // 4. 寄存器异步输出,同步写入
    Rigister  Rigister_inst (
        .clk(clk),
        .RegWr(RegWr),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .wr_data(Mem2Reg_out),
        .data1(data1),
        .data2(data2)
    );
    // 5. 控制台信号
    Control  Control_inst (
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
    // 6. imm拓展
    ext32  ext32_inst (
        .instr(instr),
        .ExtOp(ExtOp),
        .imme(imme)
    );
    // 7. Mux和Branch
    Branch_Cond  Branch_Cond_inst (
        .Branch(Branch),
        .Zero(Zero),
        .PCAsrc(PCAsrc),
        .PCBsrc(PCBsrc)
    );
    Mux_PCA  Mux_PCA_inst (
        .imme(imme),
        .PCAsrc(PCAsrc),
        .PCA_out(PCA_out)
    );
    Mux_PCB  Mux_PCB_inst (
        .PC(PC_out),
        .rs1(data1),
        .PCBsrc(PCBsrc),
        .PCB_out(PCB_out)
    );
    Mux_ALUA  Mux_ALUA_inst (
        .data1(data1),
        .PC(PC_out),
        .ALUAsrc(ALUAsrc),
        .ALUA_out(ALUA_out)
    );
    Mux_ALUB  Mux_ALUB_inst (
        .data2(data2),
        .imme(imme),
        .ALUBsrc(ALUBsrc),
        .ALUB_out(ALUB_out)
    );
    Add2  Add2_inst (
        .in1(PCA_out),
        .in2(PCB_out),
        .out(PC_new)
    );
    Mux_Mem2Reg  Mux_Mem2Reg_inst (
        .ALU_out(ALU_out),
        .Mem_Data_out(Mem_Data_out),
        .MemtoReg(MemtoReg),
        .Mem2Reg_out(Mem2Reg_out)
    );
    // 8. ALU计算
    ALU  ALU_inst (
        .data1(ALUA_out),
        .data2(ALUB_out),
        .Alu_ctrl(Alu_ctrl),
        .ALU_zero(Zero),
        .data_o(ALU_out)
    );
    // 9. 访存模块
    Data_mem  Data_mem_inst (
        .clk(clk),
        .rst(rst),
        .W_en(MemW_en),
        .R_en(MemR_en),
        .addr(ALU_out),
        .RW_Type(3'b010),   // 暂时用不上
        .din(data2),
        .dout(Mem_Data_out)
    );
endmodule
