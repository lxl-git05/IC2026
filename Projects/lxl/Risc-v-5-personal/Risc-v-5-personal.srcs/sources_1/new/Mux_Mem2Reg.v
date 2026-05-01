// 回写的路径选择器
module Mux_Mem2Reg(
        input  [31:0] ALU_out ,         // ALU计算结果
        input  [31:0] Mem_Data_out,     // lw读取结果
        input  MemtoReg ,
        output [31:0] Mem2Reg_out
    );

    assign Mem2Reg_out = MemtoReg == 1'b0 ? ALU_out : Mem_Data_out ;

endmodule
