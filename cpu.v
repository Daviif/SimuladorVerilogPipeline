module cpu (
    input wire clock,
    input wire reset
);

    // ==== Sinais e fios ====
    wire pc_write_if;
    wire if_id_write;
    wire flush_id_ex;
    wire pc_src_ctrl;
    wire flush_if_id;

    // ==== Estágio IF ====
    wire [31:0] pc_if;
    wire [31:0] pc_prox;
    wire [31:0] instrucao_if;
    wire [31:0] pc_plus4_if;
    

    // ==== Estágio ID ====
    wire [31:0] instrucao_id;
    wire [31:0] pc_plus4_id;
    wire [31:0] read_data1_id, read_data2_id;
    wire [31:0] immediate_id;
    wire [4:0] rs1_id;
    wire [4:0] rs2_id;
    wire [4:0] rd_id;

    wire branch_id, MemRead_id, MemtoReg_id, MemWrite_id, ALUSrc_id, RegWrite_id;
    wire [1:0] ALUOp_id;

    // ==== Estágio EX ====
    wire [31:0] read_data1_ex, read_data2_ex;
    wire [31:0] immediate_ex;
    wire [4:0] rs1_ex, rs2_ex, rd_ex;
    wire [31:0] pc_plus4_ex;
    wire [31:0] alu_result_ex;
    wire [3:0] alu_control_ex;
    wire zero_ex;

    wire branch_ex, MemRead_ex, MemtoReg_ex, MemWrite_ex, ALUSrc_ex, RegWrite_ex;

    // ==== Estágio MEM ====
    wire [31:0] alu_result_mem;
    wire [31:0]  read_data2_mem;
    wire [31:0]  read_data_from_mem;
    wire [4:0] rd_mem;

    wire MemRead_mem, MemtoReg_mem, MemWrite_mem, RegWrite_mem;

    // ==== Estágio WB ====
    wire [31:0] alu_result_wb;
    wire [31:0] read_data_wb;
    wire [4:0] rd_wb;
    wire [31:0] write_back_data;

    wire MemtoReg_wb, RegWrite_wb;
    
    // ==== INSTANCIAÇÃO DOS MÓDULOS DE HAZARD E FORWARDING ====

    hazard hazard(
        .rs1_id(rs1_id),
        .rs2_id(rs2_id),
        .rd_ex(rd_ex),
        .MemRead_ex(MemRead_ex),
        .pc_write(pc_write),
        .if_id_write(if_id_write),
        .flush_id_ex(flush_if_id)
    );

    wire [1:0] forwardA, forwardB;
    forwarding_unit fwd_unit (
        .rs1_ex(rs1_ex),
        .rs2_ex(rs2_ex),
        .rd_mem(rd_mem),
        .rd_wb(rd_wb),
        .RegWrite_mem(RegWrite_mem),
        .RegWrite_wb(RegWrite_wb),
        .forwardA(forwardA),
        .forwardB(forwardB)
    );

    // ==== Estágio 1: IF ====
    assign pc_plus4_if = pc_if + 4;

    mux2 #(.WIDTH(32)) pc_mux(
        .seletor(pc_src_ctrl),
        .entrada1(pc_plus4_if),
        .entrada2(alu_result_ex),
        .saida(pc_prox)
    );

    pc pc_reg(
        .clock(clock),
        .reset(reset),
        .pc_prox(pc_prox),
        .pc(pc_if),
        .pc_write(pc_write)
    );

    instruction_memory InstMem (
        .endereco(pc_if),
        .instrucao(instrucao_if)
    );

    // ==== REGISTRADOR DE PIPELINE: IF/ID ====
    if_id_register if_id_reg(
        .clock(clock),
        .reset(reset),
        .flush(flush_if_id),
        .stall(~if_id_write),
        .pc_plus4_if(pc_plus4_if),
        .instrucao_if(instrucao_if),
        .pc_plus4_id(pc_plus4_id),
        .instrucao_id(instrucao_id)
    );

    // ==== Estágio 2: ID ====
    assign rs1_id = instrucao_id[19:15];
    assign rs2_id = instrucao_id[24:20];
    assign rd_id = instrucao_id[11:7];

    control ctrl(
        .opcode(instrucao_id[6:0]),
        .Branch(branch_id),
        .MemRead(MemRead_id),
        .MemtoReg(MemtoReg_id),
        .MemWrite(MemWrite_id),
        .ALUSrc(ALUSrc_id),
        .RegWrite(RegWrite_id),
        .ALUOp(ALUOp_id)
    );

    imm_gen immGen(
        .instrucao(instrucao_id),
        .imm_out(immediate_id)
    );

    register registradores(
        .clock(clock),
        .RegWrite(RegWrite_wb),
        .rs1(rs1_id),
        .rs2(rs2_id),
        .rd(rd_wb),
        .write_data(write_back_data),
        .read_data1(read_data1_id),
        .read_data2(read_data2_id)
    );

    id_ex_register id_ex_reg (
        .clock(clock),
        .reset(reset),
        .pc_plus4_id(pc_plus4_id),
        .read_data1_id(read_data1_id),
        .read_data2_id(read_data2_id),
        .immediate_id(immediate_id),
        .rs1_id(rs1_id),
        .rs2_id(rs2_id),
        .rd_id(rd_id),
        // Sinais de controle
        .branch_id(branch_id),
        .MemRead_id(MemRead_id),
        .MemtoReg_id(MemtoReg_id),
        .MemWrite_id(MemWrite_id),
        .ALUSrc_id(ALUSrc_id),
        .RegWrite_id(RegWrite_id),
        .ALUOp_id(ALUOp_id),
        // Saídas
        .pc_plus4_ex(pc_plus4_ex),
        .read_data1_ex(read_data1_ex),
        .read_data2_ex(read_data2_ex),
        .immediate_ex(immediate_ex),
        .rs1_ex(rs1_ex),
        .rs2_ex(rs2_ex),
        .rd_ex(rd_ex),
        .branch_ex(branch_ex),
        .MemRead_ex(MemRead_ex),
        .MemtoReg_ex(MemtoReg_ex),
        .MemWrite_ex(MemWrite_ex),
        .ALUSrc_ex(ALUSrc_ex),
        .RegWrite_ex(RegWrite_ex),
        .ALUOp_ex(ALUOp_ex)
    );
    
    // ==== Estágio 3: Ex ====
    
    
    // MUXes para Forwarding
    wire [31:0] alu_input1, alu_input2;
    mux3 #(32) fwd_mux_A (
        .seletor(forwardA),
        .entrada1(read_data1_ex),     // 00: Do registrador
        .entrada2(write_back_data),   // 10: Do estágio WB
        .entrada3(alu_result_mem),    // 01: Do estágio MEM
        .saida(alu_input1)
    );
    mux3 #(32) fwd_mux_B (
        .seletor(forwardB),
        .entrada1(read_data2_ex),
        .entrada2(write_back_data),
        .entrada3(alu_result_mem),
        .saida(alu_input2)
    );

    // MUX para selecionar a segunda entrada da ALU
    wire [31:0] alu_entrada2_final;
    mux2 #(32) ALUSrc_mux (
        .seletor(ALUSrc_ex),
        .entrada1(alu_input2),
        .entrada2(immediate_ex),
        .saida(alu_entrada2_final)
    );

    alu_control aluCtrl(
        .ALUOp(ALUOp_ex),
        .funct3(immediate_ex[14:12]),
        .funct7(immediate_ex[31:25]),
        .alu_control(alu_control_ex)
    );

    alu alu(
        .entrada1(alu_input1),
        .entrada2(alu_entrada2_final),
        .alu_control(alu_control_ex),
        .resultado(alu_result_ex),
        .zero(zero_ex)
    );

    assign pc_src_ctrl = branch_ex & zero_ex;

    ex_mem_register ex_mem_reg (
        .clock(clock),
        .reset(reset),
        .alu_result_ex(alu_result_ex),
        .read_data2_ex(alu_input2), // Encaminha o valor correto para SW
        .rd_ex(rd_ex),
        // Sinais de controle
        .MemRead_ex(MemRead_ex),
        .MemtoReg_ex(MemtoReg_ex),
        .MemWrite_ex(MemWrite_ex),
        .RegWrite_ex(RegWrite_ex),
        // Saídas
        .alu_result_mem(alu_result_mem),
        .read_data2_ex(read_data2_ex),
        .rd_mem(rd_mem),
        .MemRead_mem(MemRead_mem),
        .MemtoReg_mem(MemtoReg_mem),
        .MemWrite_mem(MemWrite_mem),
        .RegWrite_mem(RegWrite_mem)
    );

    // ==== Estágio 4: Mem ====

    data_memory dataMem(
        .clock(clock),
        .MemRead(MemRead_mem),
        .MemWrite(MemWrite_mem),
        .funct3(funct3),
        .endereco(alu_result_mem),
        .write_data(read_data2_mem_in),
        .read_data(read_data_mem)
    );

    mem_wb_register mem_wb_reg (
        .clock(clock),
        .reset(reset),
        .read_data_mem(read_data_mem),
        .alu_result_mem(alu_result_mem),
        .rd_mem(rd_mem),
        // Sinais de controle
        .MemtoReg_mem(MemtoReg_mem),
        .RegWrite_mem(RegWrite_mem),
        // Saídas
        .read_data_wb(read_data_wb),
        .alu_result_wb(alu_result_wb),
        .rd_wb(rd_wb),
        .MemtoReg_wb(MemtoReg_wb),
        .RegWrite_wb(RegWrite_wb)
    );

    // ==== Estágio 5: WB

    // Write Back

    mux2 #(.WIDTH(32)) write_back_mux(
        .seletor(MemtoReg_wb),
        .entrada1(alu_result_wb),
        .entrada2(read_data_wb),
        .saida(write_back_data)
    );


endmodule