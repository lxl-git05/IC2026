module ALU(
    input [31:0] data1,
    input [31:0] data2,
    input [3:0] Alu_ctrl,

    output reg [31:0] data_o
);

    always @(*)
    begin
        case(Alu_ctrl)

            4'b0000: data_o = data1 + data2;
            4'b0001: data_o = data1 - data2;
            4'b0010: data_o = data1 & data2;
            4'b0011: data_o = data1 | data2;
            4'b0100: data_o = data1 ^ data2;
            4'b0101: data_o = data1 << data2[4:0];
            4'b0110: data_o = data1 >> data2[4:0];
            4'b0111: data_o = $signed(data1) >>> data2[4:0];
            4'b1000: data_o = ($signed(data1) < $signed(data2));
            4'b1001: data_o = (data1 < data2);

            default: data_o = 0;

        endcase
    end

endmodule
