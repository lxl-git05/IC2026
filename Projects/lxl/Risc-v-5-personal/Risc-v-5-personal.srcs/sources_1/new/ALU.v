module ALU(
    input  [31:0] data1,
    input  [31:0] data2,
    input  [3:0]  Alu_ctrl,

    output wire ALU_zero,
    output reg  [31:0] data_o
);

always @(*) begin
    case(Alu_ctrl)

        4'b0000: data_o = data1 + data2;                          // add
        4'b0001: data_o = data1 - data2;                          // sub
        4'b0010: data_o = data1 & data2;                          // and
        4'b0011: data_o = data1 | data2;                          // or
        4'b0100: data_o = data1 ^ data2;                          // xor
        4'b0101: data_o = data1 << data2[4:0];                    // sll
        4'b0110: data_o = data1 >> data2[4:0];                    // srl
        4'b0111: data_o = $signed(data1) >>> data2[4:0];          // sra
        4'b1000: data_o = ($signed(data1) < $signed(data2)) ?
                          32'd1 : 32'd0;                          // slt
        4'b1001: data_o = (data1 < data2) ?
                          32'd1 : 32'd0;                          // sltu

        default: data_o = 32'b0;

    endcase
end

assign ALU_zero = (data_o == 32'b0);    // rs1 != rs2, zero就为0

endmodule
