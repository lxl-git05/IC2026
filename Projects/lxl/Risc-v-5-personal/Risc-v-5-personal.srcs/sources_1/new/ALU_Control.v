module ALU_Control(
    input [6:0] op,
    input [2:0] func3,
    input [6:0] func7,

    output reg [3:0] Alu_ctrl
);

always @(*)
begin
    case(op)
        // R-Type
        7'b0110011:
        begin
            case(func3)

                3'b000:
                begin
                    if(func7 == 7'b0000000)
                        Alu_ctrl = 4'b0000; // ADD
                    else if(func7 == 7'b0100000)
                        Alu_ctrl = 4'b0001; // SUB
                end

                3'b111:
                    Alu_ctrl = 4'b0010; // AND

                3'b110:
                    Alu_ctrl = 4'b0011; // OR

                3'b100:
                    Alu_ctrl = 4'b0100; // XOR

                3'b001:
                    Alu_ctrl = 4'b0101; // SLL

                3'b101:
                begin
                    if(func7 == 7'b0000000)
                        Alu_ctrl = 4'b0110; // SRL
                    else if(func7 == 7'b0100000)
                        Alu_ctrl = 4'b0111; // SRA
                end

                3'b010:
                    Alu_ctrl = 4'b1000; // SLT

                3'b011:
                    Alu_ctrl = 4'b1001; // SLTU

            endcase
        end

        // I-Type
        7'b0010011:
        begin
            case(func3)

                3'b000:
                    Alu_ctrl = 4'b0000; // ADDI

                3'b111:
                    Alu_ctrl = 4'b0010; // ANDI

                3'b110:
                    Alu_ctrl = 4'b0011; // ORI

                3'b100:
                    Alu_ctrl = 4'b0100; // XORI

            endcase
        end

        // Load
        7'b0000011:
            Alu_ctrl = 4'b0000;

        // Store
        7'b0100011:
            Alu_ctrl = 4'b0000;

        // Branch
        7'b1100011:
            Alu_ctrl = 4'b0001;

        default:
            Alu_ctrl = 4'b0000;

    endcase
end

endmodule
