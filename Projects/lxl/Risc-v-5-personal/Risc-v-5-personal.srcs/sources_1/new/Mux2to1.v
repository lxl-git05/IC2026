module Mux2to1(
        input  [31:0] data1,
        input  [31:0] data2,
        input  sel ,
        output [31:0] out
    );
    
    assign out = (sel == 1'b0 ? data1 : data2) ;

endmodule
