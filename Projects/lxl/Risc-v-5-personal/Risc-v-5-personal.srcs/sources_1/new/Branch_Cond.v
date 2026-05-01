module Branch_Cond(
        input [2:0] Branch ,
        input Zero ,
        output PCAsrc,
        output PCBsrc
    );

    wire branch_take;

    assign branch_take =
        (Branch == 3'b100 && Zero) ||             // BEQ
        (Branch == 3'b101 && !Zero) ;             // BNE


    assign PCAsrc =
        (Branch == 3'b001) ||                    // JAL
        (Branch == 3'b010) ||                    // JALR
        branch_take;                             // 条件分支


    assign PCBsrc = (Branch == 3'b010);

endmodule
