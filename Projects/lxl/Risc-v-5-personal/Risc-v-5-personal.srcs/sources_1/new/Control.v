module Control(
        input [6:0] op,
        input [2:0] func3,
        input [6:0] func7,

        // 切记位宽
        output RegWr ,             // 寄存器写入使能
        output ALUAsrc,             // Rs1的选择器
        output ALUBsrc,             // Rs2的选择器
        output reg [3:0] Alu_ctrl   // ALU的控制信号
    );  

    assign RegWr  = ((op == 7'b0110011) || (op == 7'b0010011) ? 1'b1 : 1'b0) ; // 7'b0110011对应R型指令 , 7'b0010011对应I
    assign ALUAsrc = 1'b1;
    assign ALUBsrc = 1'b1;

    always @(*)
    begin
        case(op)
            7'b0110011: // R-Type
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
            7'b0010011: // I-Type
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
            7'b0000011: // Load
                Alu_ctrl = 4'b0000;
            7'b0100011: // Store
                Alu_ctrl = 4'b0000;
            7'b1100011: // Branch
                Alu_ctrl = 4'b0001;
            default:
                Alu_ctrl = 4'b0000;
        endcase
    end
endmodule
