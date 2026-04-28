// 取指
module Instr_mem (
    input  wire [31:0] addr ,
    output reg  [31:0] instr
);
    // 指令存储
    reg [7:0] instr_mem [0:1023];
    // 

endmodule