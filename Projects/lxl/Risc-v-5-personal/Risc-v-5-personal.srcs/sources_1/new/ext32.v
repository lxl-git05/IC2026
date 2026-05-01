module ext32(
    input  [31:0] instr,
    input  [2:0]  ExtOp,
    output reg [31:0] imme
);

always @(*) begin
    case(ExtOp)
        // I-type
        3'b000:
            imme = {{20{instr[31]}}, instr[31:20]};
        // U-type
        3'b001:
            imme = {instr[31:12], 12'b0};
        // S-type
        3'b010:
            imme = {{20{instr[31]}},
                    instr[31:25],
                    instr[11:7]};
        // B-type
        3'b011:
            imme = {{19{instr[31]}},
                    instr[31],
                    instr[7],
                    instr[30:25],
                    instr[11:8],
                    1'b0};  // 左移一位+PC,这里实现了左移
        // J-type
        3'b100:
            imme = {{11{instr[31]}},
                    instr[31],
                    instr[19:12],
                    instr[20],
                    instr[30:21],
                    1'b0};  // 左移一位+PC,这里实现了左移
        default:
            imme = 32'b0;
    endcase
end

endmodule
