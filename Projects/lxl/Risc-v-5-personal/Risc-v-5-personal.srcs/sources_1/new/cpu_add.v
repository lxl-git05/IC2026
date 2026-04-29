module cpu_add(
        input wire clk ,
        input wire rst
    );
    // 定义内部线
    wire [31:0] PC   ;  // PC指针
    wire [31:0] addr ;  // ROM返回指令地址
    wire [31:0] instr;  // 指令

    // 指令解码
    wire [6:0] op    ;
    wire [2:0] func3 ;
    wire [6:0] func7 ;

    wire [4:0] rd    ;
    wire [4:0] rs1   ;
    wire [4:0] rs2   ;

    // 控制线
    wire wr_en ;

    // ALU
    wire [ 3:0] Alu_ctrl;
    wire [31:0] data1   ;
    wire [31:0] data2   ;
    wire [31:0] data_o  ; 

    // 例化逻辑

    // 1. PC端口
    PC  U_PC (
        .clk(clk),
        .rst(rst),
        .addr(addr)
    );

    // 2. instr_mem(ROM根据PC指针返回指令)
    Instr_mem  U_Instr_mem (
        .addr(addr),
        .instr(instr)
    );

    // 3. Decode解码
    Decode  U_Decode (
        .instr(instr),
        .func7(func7),
        .rs2(rs2),
        .rs1(rs1),
        .func3(func3),
        .rd(rd),
        .op(op)
    );

    // 4. Control控制寄存器Register
    Control  U_Control (
        .op(op),
        .wr_en(wr_en)
    );

    // 5. ALU控制台
    ALU_Control  U_ALU_Control (
        .op(op),
        .func3(func3),
        .func7(func7),
        .Alu_ctrl(Alu_ctrl)
    ) ;

    // 6. ALU计算
    ALU  U_ALU (
        .data1(data1),
        .data2(data2),
        .Alu_ctrl(Alu_ctrl),
        .data_o(data_o)
    );

    // 7. 回写写入寄存器
    Rigister  U_Rigister (
        .clk(clk),
        .wr_en(wr_en),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .wr_data(data_o),
        .data1(data1),
        .data2(data2)
    );

    // 检查参数
    always @(posedge clk)
    begin
        if(!rst)
        begin
            $display("\n========================================");
            $display("PC        : %h", PC);
            $display("addr      : %h", addr);
            $display("Instr     : %h", instr);

            $display("opcode    : %b", op);
            $display("func3     : %b", func3);
            $display("func7     : %b", func7);

            $display("rs1       : %d", rs1);
            $display("rs2       : %d", rs2);
            $display("rd        : %d", rd);

            $display("data1     : %d", data1);
            $display("data2     : %d", data2);

            $display("ALU ctrl  : %b", Alu_ctrl);
            $display("ALU out   : %d", data_o);

            $display("wr_en     : %b", wr_en);
            $display("========================================");
        end
    end

endmodule
