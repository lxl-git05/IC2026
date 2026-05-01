module Control(
        input [6:0] op,
        input [2:0] func3,
        input [6:0] func7,

        // 切记位宽
        output wire [2:0] ExtOp ,   // imm扩展类型信号
        output RegWr ,              // 寄存器写入使能
        output ALUAsrc,             // Rs1的选择器
        output [1:0]ALUBsrc,        // Rs2的选择器
        output reg [3:0] Alu_ctrl,  // ALU的控制信号
        output reg [2:0] Branch,    // B型信号的Mux控制PC值
        output MemtoReg,            // 回写的Mux选择器
        output MemW_en,             // 内存写入使能
        output MemR_en              // 内存读取使能
    );  

    // 先得到类型,好进行下面的分析 (暂时不支持U型指令)
    wire R_type;
    wire I_type;
    wire U_type ;
    wire Load_type;
    wire Store_type;
    wire Branch_type;
    wire JAL_type;
    wire JALR_type;

    assign R_type      = (op == 7'b0110011);
    assign I_type      = (op == 7'b0010011);
    assign Load_type   = (op == 7'b0000011);
    assign Store_type  = (op == 7'b0100011);
    assign Branch_type = (op == 7'b1100011);
    assign JAL_type    = (op == 7'b1101111);
    assign JALR_type   = (op == 7'b1100111);
    assign U_type      = (op == 7'b0110111) || (op == 7'b0010111); // LUI/AUIPC

    // 立即数扩展
    assign ExtOp =
    (I_type || Load_type || JALR_type) ? 3'b000 :
    Store_type                         ? 3'b010 :
    Branch_type                        ? 3'b011 :
    JAL_type                           ? 3'b100 :   3'b000;

    assign RegWr =
        (R_type ||
        I_type ||
        Load_type ||
        JAL_type ||
        JALR_type ||
        U_type ) ? 1'b1 : 1'b0 ;
    assign ALUAsrc = JAL_type ;

    assign ALUBsrc =
    (R_type || Branch_type) ? 2'b00 :
    JAL_type                ? 2'b10 :
                              2'b01;
    
    always @(*) begin
        Branch = 3'b000;

        if(JAL_type)
            Branch = 3'b001;

        else if(JALR_type)
            Branch = 3'b010;

        else if(Branch_type) begin
            case(func3)
                3'b000: Branch = 3'b100; // BEQ
                3'b001: Branch = 3'b101; // BNE
                default: Branch = 3'b000;
            endcase
        end
    end

    assign MemtoReg = Load_type ;

    assign MemW_en = Store_type;
    assign MemR_en = Load_type;

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
