`timescale 1ns / 1ps
module ifetch(
        // PC输入指令地址
        input  wire [31:0] pc_addr_i,
        // ROM输入指令
        input  wire [31:0] rom_inst_i,
        // 
        output wire [31:0] if2rom_addr_o,
        output wire [31:0] intst_addr_o,
        output wire [31:0] inst_o
    );
    
    
endmodule
