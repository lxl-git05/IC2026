`include "Ctrl-signal-def.v"
`include "instruction-def.v"
module ALU(A,B,ALUOp,zero,ALU_result);
    input signed [31:0] A;
    input signed [31:0] B;
    input [3:0] ALUOp;
    output zero;
    output reg signed [31:0] ALU_result;

    // 书写逻辑
    always @(*) begin
        case(ALUOp)

            4'b0000: ALU_result = A + B;                          // add
            4'b0001: ALU_result = A - B;                          // sub
            4'b0010: ALU_result = A & B;                          // and
            4'b0011: ALU_result = A | B;                          // or
            4'b0100: ALU_result = A ^ B;                          // xor
            4'b0101: ALU_result = A << B[4:0];                    // sll
            4'b0110: ALU_result = A >> B[4:0];                    // srl
            4'b0111: ALU_result = $signed(A) >>> B[4:0];          // sra
            4'b1000: ALU_result = ($signed(A) < $signed(B)) ?
                            32'd1 : 32'd0;                        // slt
            4'b1001: ALU_result = ($unsigned(A) < $unsigned(B)) ?
                            32'd1 : 32'd0;                       // sltu

            default: ALU_result = 32'b0;

        endcase
    end

    assign zero = (ALU_result == 32'b0);    // A != B, zero就为0

endmodule
