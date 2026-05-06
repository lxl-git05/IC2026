`timescale 1ns / 1ps
`include "Ctrl-signal-def.v"
`include "instruction-def.v"
module ControlUnit(
    input rst,
    input clk,
    input zero,
    input [6:0] opcode,
    input [6:0] Funct7,
    input [2:0] Funct3,
    output wire PCWrite,         // IF阶段,恒为1,除非暂停
    output wire InsMemRW,        // IF阶段,恒为1
    output wire IRWrite,         // IF_ID的锁存信号,暂时恒为1,除非暂停
    output reg  RFWrite,         // 在ID阶段就使用,不需要打拍
    output reg  DMCtrl,          // MEM
    output wire ExtSel,          // 在ID阶段就使用,不需要打拍
    output reg [1:0] ALUSrcA,    // EX,位宽修改
    output reg [2:0] ALUSrcB,    // EX,位宽修改
    output wire [1:0] RegSel,    // 在ID阶段就使用,不需要打拍
    output reg [1:0] NPCOp,      // EX
    output reg [1:0] WDSel,      // WB
    output reg [3:0] ALUOp,      // EX

    input [4:0] rs1 , rs2 , rd,  // 新增: rd,用来判断数据是否需要前递
    output wire flush            // 新增: 流水线flush信号,冲刷控制冲突下多余的指令
);

    // ======================== 先得到类型,好进行下面的分析 (暂时不支持U型指令) ========================
    wire R_type;            assign R_type      = (opcode === 7'b0110011) ? 1'b1 : 1'b0;
    wire I_type;            assign I_type      = (opcode === 7'b0010011) ? 1'b1 : 1'b0;                   
    wire Load_type;         assign Load_type   = (opcode === 7'b0000011) ? 1'b1 : 1'b0;
    wire Store_type;        assign Store_type  = (opcode === 7'b0100011) ? 1'b1 : 1'b0;
    wire Branch_type;       assign Branch_type = (opcode === 7'b1100011) ? 1'b1 : 1'b0;
    wire JAL_type;          assign JAL_type    = (opcode === 7'b1101111) ? 1'b1 : 1'b0;
    wire JALR_type;         assign JALR_type   = (opcode === 7'b1100111) ? 1'b1 : 1'b0;
    wire BEQ_type;          assign BEQ_type    = (opcode === 7'b1100011 && Funct3 === 3'b000) ? 1'b1 : 1'b0;
    wire BNE_type;          assign BNE_type    = (opcode === 7'b1100011 && Funct3 === 3'b001) ? 1'b1 : 1'b0;
    
    // ======================== 流水线信号定义 ========================
    // ID阶段
    wire RFWrite_ID;
    wire DMCtrl_ID;
    wire [1:0] ALUSrcA_ID;
    wire [2:0] ALUSrcB_ID;
    wire [1:0] NPCOp_ID;
    wire [1:0] WDSel_ID;
    reg  [3:0] ALUOp_ID;
    // EX阶段
    reg RFWrite_EX;
    reg DMCtrl_EX;
    reg [1:0] ALUSrcA_EX;
    reg [2:0] ALUSrcB_EX;
    reg [1:0] NPCOp_EX;
    reg [1:0] WDSel_EX;
    reg [3:0] ALUOp_EX;
    // MEM阶段
    reg RFWrite_MEM;
    reg DMCtrl_MEM;
    reg [1:0] WDSel_MEM;
    // WB阶段
    reg RFWrite_WB;
    reg [1:0] WDSel_WB;

    // 新增控制信号定义
    // rd打拍延迟
    reg [4:0] rd_delay_1;  // 延迟1拍(也就是EX的数据前递)
    reg [4:0] rd_d1;
    reg [4:0] rd_delay_2;  // 延迟2拍(也就是MEM的数据前递),而wb写回可以通过下降沿写回实现前递,所以不需要rd_delay_3
    wire stall ;            // 流水线暂停标志
    wire load_use_hazard;   // 判断是否产生冲突4:lw与addi相邻冲突
    wire BranchTaken;

    // ======================== 数据冲突1,2,3: ALU结果前递到EX阶段 ========================
    // 打拍
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            rd_delay_1 <= 5'b0;
            rd_d1      <= 5'b0;
            rd_delay_2 <= 5'b0;
        end
        else begin
            // 1拍延迟
            rd_delay_1 <= (rd === 5'bx) ? 5'b0 : rd;
            // 2拍延迟
            rd_d1      <= (rd === 5'bx) ? 5'b0 : rd;
            rd_delay_2 <= rd_d1;
        end
    end
    // 确定在ex_mem或mem_wb阶段是在进行数据写入的指令,并且目的寄存器不是x0,并且目的寄存器和当前指令的rs1相同,则需要前递
    assign ALUSrcA_ID = (stall | BranchTaken) ? 2'b00 :
                        (RFWrite_EX && rd_delay_1 != 0 && rd_delay_1 == rs1) ? 2'b10 : 
                        (RFWrite_MEM  && rd_delay_2 != 0 && rd_delay_2 == rs1) ? 2'b11 : 2'b00 ;
    // 确定在ex_mem或mem_wb阶段是在进行数据写入的指令,并且目的寄存器不是x0,并且目的寄存器和当前指令的rs2相同,则需要前递
    assign ALUSrcB_ID = (stall | BranchTaken) ? 3'b000 :
                        ((R_type| Branch_type) && RFWrite_EX && rd_delay_1 != 0 && rd_delay_1 == rs2) ? 3'b011 : 
                        ((R_type| Branch_type) && RFWrite_MEM  && rd_delay_2 != 0 && rd_delay_2 == rs2) ? 3'b100 : 
                        (R_type) ? 3'b000 :
                        (I_type | Load_type | JALR_type) ? 3'b001 :
                        (Store_type | JAL_type) ? 3'b010 : 3'b000 ;

    // ======================== 数据冲突4: lw和addi相邻冲突 ========================
    // load_Type 打拍: ID阶段下检查EX阶段是否为Load,所以需要在本阶段打1拍
    reg Load_EX;
    always @(posedge clk or posedge rst) begin
        if (rst)
            Load_EX <= 1'b0;
        else
            Load_EX <= (Load_type === 1'bx) ? 1'b0 : Load_type;
    end
    
    // rd打拍: rd_delay_1 已经定义了,就是EX阶段的rd
    wire hazard_raw;
    assign hazard_raw = Load_EX && (rd_delay_1 != 0) && ((rd_delay_1 == rs1) || ((R_type || Store_type || Branch_type) && (rd_delay_1 == rs2)));
    assign load_use_hazard = (hazard_raw === 1'bx) ? 1'b0 : hazard_raw;

    // 如果产生lw冲突,则需要暂停流水线,冻结PC和IR,并且在ID阶段(也就是接下来的EX)注入气泡(将控制信号置0)
    assign PCWrite = rst ? 0 : stall ? 0 : 1 ;
    assign IRWrite = rst ? 0 : stall ? 0 : 1 ;

    // ID注入气泡,下放到各个ID阶段的Control

    // ======================== BNE和BEQ与Zreo处理 ========================
    // ID阶段的Type打1拍到EX阶段使用
    reg BNE_Type_EX; reg BEQ_Type_EX;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            BNE_Type_EX <= 1'b0;
            BEQ_Type_EX <= 1'b0;
        end
        else begin
            BNE_Type_EX <= (BNE_type === 1'bx) ? 1'b0 : BNE_type;
            BEQ_Type_EX <= (BEQ_type === 1'bx) ? 1'b0 : BEQ_type;
        end
    end
    // 在EX阶段根据指令类型和zero信号判断是否需要跳转,如果是BEQ指令且zero为1,或者是BNE指令且zero为0,则需要跳转
    // 所以需要修改NPCOp的生成逻辑,如果是BEQ指令且zero为1,或者是BNE指令且zero为0,则NPCOp为Offset12,否则继续为NPC_EX
    always @(*) begin
        // EX 级信号,NPCOp进行特殊处理
        NPCOp = (BNE_Type_EX && zero == 1'b0) || (BEQ_Type_EX && zero == 1'b1) ? `NPC_Offset12 : NPCOp_EX ;
    end

    // ======================== 控制冲突处理(jal,jalr,bne,beq都在EX阶段处理) ========================
    assign BranchTaken =
    (BNE_Type_EX && !zero) ||           // BNE
    (BEQ_Type_EX && zero) ||            // BEQ
    (NPCOp_EX == `NPC_Offset20) ||      // jal
    (NPCOp_EX == `NPC_rs);              // jalr
    assign flush = BranchTaken;
    // 如果冲突,那么就开始进行flush冲刷处理
    // ID阶段的ID信号进行flush处理,也就是置0,相当于注入气泡,但是不同于lw对于addi的冲突,这里不需要冻结PCWrite
    // IF阶段的out_ins信号进行Nop改写

    // ======================== 控制冲突与数据冲突处理(lw,sw,jal,jalr,bne,beq在EX阶段的数据还未更新, 统一进行stall处理) ========================
    wire store_hazard;
    assign store_hazard =
    Store_type &&
    (
        (RFWrite_EX  && rd_delay_1 != 0 && rd_delay_1 == rs2) ||
        (RFWrite_MEM && rd_delay_2 != 0 && rd_delay_2 == rs2)
    );
    wire jalr_hazard;
    assign jalr_hazard =
    JALR_type &&
    (
        (RFWrite_EX  && rd_delay_1 != 0 && rd_delay_1 == rs1) ||
        (RFWrite_MEM && rd_delay_2 != 0 && rd_delay_2 == rs1)
    );
    assign stall = (load_use_hazard | store_hazard | jalr_hazard) ? 1'b1 : 1'b0 ;

    // ======================== 一般组合逻辑 ========================
    // ID阶段信号的组合逻辑,根据指令类型和功能码生成控制信号
    assign InsMemRW = rst ? 1'b0 : 1'b1 ;    // 每个周期都要读指令
    assign RegSel  = `RegSel_rd ;       // 默认使用rd作为目的寄存器,其他指令也无所谓

    assign RFWrite_ID  = rst ? 1'b0 : (stall | BranchTaken) ? 1'b0 : R_type | I_type | Load_type | JAL_type | JALR_type;
    assign DMCtrl_ID   = (stall | BranchTaken) ? 1'b0 : Store_type ;       // Store指令写内存,其他指令不写内存
    assign ExtSel =
        (I_type && (
            Funct3 == 3'b110 ||
            Funct3 == 3'b111 ||
            Funct3 == 3'b100 )) ? `ExtSel_ZERO : `ExtSel_SIGNED;
    assign NPCOp_ID   = // 注意: 这里直接忽略了B型指令的跳转情况,因为ID阶段无法知道zero信号,所以只能在EX阶段进行修改
        (load_use_hazard | BranchTaken) ? `NPC_PC :
        (Branch_type) ? `NPC_PC :           // 默认不跳转
        (JAL_type)    ? `NPC_Offset20 : 
        (JALR_type)   ? `NPC_rs : `NPC_PC ;
    assign WDSel_ID = (stall | BranchTaken) ? `WDSel_FromALU : Load_type ? `WDSel_FromMEM : 
                   (JAL_type | JALR_type)  ? `WDSel_FromPC : `WDSel_FromALU ;
    

    // ALU控制信号
    always @(*)
    begin
        case(opcode)
            7'b0110011: // R-Type
            begin
                case(Funct3)
                    3'b000:
                    begin
                        if(Funct7 == 7'b0000000)
                            ALUOp_ID = 4'b0000; // ADD
                        else if(Funct7 == 7'b0100000)
                            ALUOp_ID = 4'b0001; // SUB
                    end
                    3'b111:
                        ALUOp_ID = 4'b0010; // AND
                    3'b110:
                        ALUOp_ID = 4'b0011; // OR
                    3'b100:
                        ALUOp_ID = 4'b0100; // XOR
                    3'b001:
                        ALUOp_ID = 4'b0101; // SLL
                    3'b101:
                    begin
                        if(Funct7 == 7'b0000000)
                            ALUOp_ID = 4'b0110; // SRL
                        else if(Funct7 == 7'b0100000)
                            ALUOp_ID = 4'b0111; // SRA
                    end
                    3'b010:
                        ALUOp_ID = 4'b1000; // SLT
                    3'b011:
                        ALUOp_ID = 4'b1001; // SLTU
                endcase
            end
            7'b0010011: // I-Type
            begin
                case(Funct3)
                    3'b000:
                        ALUOp_ID = 4'b0000; // ADDI
                    3'b111:
                        ALUOp_ID = 4'b0010; // ANDI
                    3'b110:
                        ALUOp_ID = 4'b0011; // ORI
                    3'b100:
                        ALUOp_ID = 4'b0100; // XORI
                endcase
            end
            7'b0000011: // Load
                ALUOp_ID = 4'b0000;
            7'b0100011: // Store
                ALUOp_ID = 4'b0000;
            7'b1100011: // Branch
                ALUOp_ID = 4'b0001;
            7'b1100111: //JALR
                ALUOp_ID = 4'b0000;// 执行加法 rs1 +imm
            default:
                ALUOp_ID = 4'b0000;
        endcase
    end
    // ======================== 流水线信号传输 ========================
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // 复位时清空所有流水线控制信号（注入气泡）
            RFWrite_EX  <= 0;
            DMCtrl_EX   <= 0;
            ALUSrcA_EX  <= 2'b00;
            ALUSrcB_EX  <= 3'b000;
            NPCOp_EX    <= 2'b00;
            WDSel_EX    <= 2'b00;
            ALUOp_EX    <= 4'b0000;
            RFWrite_MEM <= 0;
            DMCtrl_MEM  <= 0;
            WDSel_MEM   <= 2'b00;
            RFWrite_WB  <= 0;
            WDSel_WB    <= 2'b00;
        end else begin
            // 每一个时钟上升沿，信号向后传递一拍
            // ID -> EX
            RFWrite_EX  <= RFWrite_ID;
            DMCtrl_EX   <= DMCtrl_ID;
            ALUSrcA_EX  <= ALUSrcA_ID;
            ALUSrcB_EX  <= ALUSrcB_ID;
            NPCOp_EX    <= NPCOp_ID;        // 这里由于需要B型跳转,所以需要与zero进行判断比较,所以是NPCOp的选项之一
            WDSel_EX    <= WDSel_ID;
            ALUOp_EX    <= ALUOp_ID;

            // EX -> MEM
            RFWrite_MEM <= RFWrite_EX;
            DMCtrl_MEM  <= DMCtrl_EX;
            WDSel_MEM   <= WDSel_EX;
            // MEM -> WB
            RFWrite_WB  <= RFWrite_MEM;
            WDSel_WB    <= WDSel_MEM;
        end
    end
    // 信号输出: 将不同阶段的寄存器值赋给最终输出端口
    always @(*) begin
        // EX 级信号
        ALUSrcA = ALUSrcA_EX ;
        ALUSrcB = ALUSrcB_EX ;
        // NPCOp = NPCOp_EX     ;
        ALUOp = ALUOp_EX     ;
        // MEM 级信号
        DMCtrl   = DMCtrl_MEM;
        // WB 级信号
        RFWrite  = RFWrite_WB;
        WDSel    = WDSel_WB;
    end
endmodule