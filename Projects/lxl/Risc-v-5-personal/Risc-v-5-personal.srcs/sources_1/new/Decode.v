module Decode(
        input  [31: 0] instr ,
        output [ 6: 0] func7 ,
        output [ 4: 0]   rs2 ,
        output [ 4: 0]   rs1 ,
        output [ 2: 0] func3 ,
        output [ 4: 0]    rd ,
        output [ 6: 0]    op 
    );
    // 书写逻辑
    assign func7 = instr[31:25];
    assign rs2   = instr[24:20];
    assign rs1   = instr[19:15];
    assign func3 = instr[14:12];
    assign rd    = instr[11: 7];
    assign op    = instr[ 6: 0];

endmodule
