`timescale 1 ps / 1 ps

module riscv_sim ();

// Inputs
reg clk, rst;

riscv U_RISCV(
    .clk(clk), .rst(rst)
);

initial begin
    // $readmemh ("../hex/code.hex", U_RISCV.U_IM.memory);
    $readmemh ("E:/IC_Competition/IC2026/Projects/Risc-v-v1/cpu_test.txt", U_RISCV.U_IM.memory);
    // $readmemh ("E:/IC_Competition/IC2026/Projects/Risc-v-v1/cpu_test.hex", U_RISCV.U_IM.memory);
    // $display("Instruction memory initialized");
    // $monitor("PC = 0x%8X, IR = 0x%8X",U_RISCV.U_PC.PC, U_RISCV.out_ins );
    clk = 1 ;

    #5 ;
    rst = 1 ;
    #20 ;
    rst = 0 ;
end

always
    // #(50) clk = ~clk;
    #(5) clk = ~clk;

// initial begin
//     $fsdbDumpvars(0,"riscv_sim");
//     $fsdbDumpMDA(0,"riscv_sim");
// end

endmodule