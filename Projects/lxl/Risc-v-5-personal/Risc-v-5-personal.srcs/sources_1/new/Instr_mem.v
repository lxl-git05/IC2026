// 取指
module Instr_mem (
    input  wire [31:0] addr ,
    output reg  [31:0] instr
);
    // 指令存储
    reg [7:0] instr_mem [0:1023];   // 位宽:8 总数:数组容量 = 1024
    //初始化时将指令写入存储器, readmemh和readmemb一定要甄别
    initial $readmemh("E:/IC_Competition/IC2026/Projects/lxl/Risc-v-5-personal/rom.txt",instr_mem); 
    // 填入指令:大端
    always@(*)begin
        instr[7:0]   = instr_mem[addr+3];
        instr[15:8]  = instr_mem[addr+2];
        instr[23:16] = instr_mem[addr+1];
        instr[31:24] = instr_mem[addr];
    end
endmodule
