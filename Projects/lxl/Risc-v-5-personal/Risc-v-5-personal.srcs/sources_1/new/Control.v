module Control(
        input  [6:0] op ,
        output wr_en
    );  

    // 控制信号,控制Rigister的操作 
    assign wr_en = (op == 7'b0110011 ? 1'b1 : 1'b0) ; // 7'b0110011 对应 R型指令
endmodule
