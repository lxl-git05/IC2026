module cpu_I_Type(
        input wire clk ,
        input wire rst
    );

    // // 1. PC端口
    // wire [31:0] addr ;  // ROM返回指令地址
    // // 2. instr_mem(ROM根据PC指针返回指令)
    // wire [31:0] instr;  // 指令
    // // 3. Decode解码
    // wire [6:0] op    ;
    // wire [2:0] func3 ;
    // wire [6:0] func7 ;

    // wire [4:0] rd    ;
    // wire [4:0] rs1   ;
    // wire [4:0] rs2   ;

    // wire [11:0] imm  ;      // I型指令:imm
    // // 4. Imm拓展
    // wire [31:0] ext_imm  ;  // I型指令:ext_imm
    // // 5. Control控制器
    // wire RegWr ;
    // wire ALUAsrc ;
    // wire ALUBsrc ;
    // wire [ 3:0] Alu_ctrl;
    // // 6. ALU计算
    // wire [31:0] in1   ;     // 输入1
    // wire [31:0] in2   ;     // 输入2
    // wire [31:0] data_o  ; 
    // // 7. Register寄存器
    // wire [31:0] data1   ;   // BusA
    // wire [31:0] data2   ;   // BusB
    // // Mux选择器



    // // 1. PC端口
    // PC  U_PC (
    //     .clk(clk),
    //     .rst(rst),
    //     .addr(addr)
    // );

    // // 2. instr_mem(ROM根据PC指针返回指令)
    // Instr_mem  U_Instr_mem (
    //     .addr(addr),
    //     .instr(instr)
    // );
    
    // // 3. Decode解码
    // Decode  U_Decode (
    //     .instr(instr),
    //     .func7(func7),
    //     .rs2(rs2),
    //     .rs1(rs1),
    //     .func3(func3),
    //     .rd(rd),
    //     .op(op),
    //     .imm(imm)
    // );
    
    // // 4. Imm拓展
    // ext12to32  U_ext12to32 (
    //     .imm(imm),
    //     .ext_imm(ext_imm)
    // );

    // // 5. Control控制寄存器Register
    // Control  Control_inst (
    //     .op(op),
    //     .func3(func3),
    //     .func7(func7),
    //     .RegWr(RegWr),
    //     .ALUAsrc(ALUAsrc),
    //     .ALUBsrc(ALUBsrc),
    //     .Alu_ctrl(Alu_ctrl)
    // );

    // // 6. ALU计算
    // ALU  U_ALU (
    //     .data1(in1),
    //     .data2(in2),
    //     .Alu_ctrl(Alu_ctrl),
    //     .data_o(data_o)
    // );

    // // 7. 回写写入寄存器
    // Rigister  U_Rigister (
    //     .clk(clk),
    //     .RegWr(RegWr),
    //     .rs1(rs1),
    //     .rs2(rs2),
    //     .rd(rd),
    //     .wr_data(data_o),
    //     .data1(data1),
    //     .data2(data2)
    // );

    // // Mux选择器
    // Mux2to1  U_Mux2to1_A (
    //     .data1(32'd0),
    //     .data2(data1),  // BusA
    //     .sel(ALUAsrc),
    //     .out(in1)
    // );

    // Mux2to1  U_Mux2to1_B (
    //     .data1(data2),  // BusB
    //     .data2(ext_imm),
    //     .sel(ALUBsrc),
    //     .out(in2)
    // );


endmodule
