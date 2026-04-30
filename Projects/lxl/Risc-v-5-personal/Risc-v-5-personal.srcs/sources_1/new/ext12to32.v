// 12位imm扩展成32位
module ext12to32(
        input  [11:0] imm, 
        output [31:0] ext_imm
    );

    assign ext_imm = {{20{imm[11]}},imm};   // 根据imm的最高位确定imm的扩展方式
    
endmodule
