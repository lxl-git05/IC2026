// 取指
module Instr_mem (
    input  wire [31:0] addr ,
    output wire [31:0] instr
);
    // 指令存储
    reg [31:0] instr_mem [0:1023];   // 位宽:8 总数:数组容量 = 1024
    //初始化时将指令写入存储器, readmemh和readmemb一定要甄别
    initial $readmemh("E:/IC_Competition/IC2026/Projects/lxl/Risc-v-5-personal/rom.txt",instr_mem); 
    // 填入指令:大端(txt里面有体现)
    assign instr = instr_mem[addr >> 2];    // 也就是addr / 4 (PC += 4, 但是取指令只需要+1)
endmodule
