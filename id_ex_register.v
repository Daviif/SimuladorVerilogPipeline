module id_ex_register(
    input wire clock,
    input wire reset,
    input wire [31:0] pc_plus4_id,
    input wire [31:0] read_data1_id,
    input wire [31:0] read_data2_id,
    input wire [31:0] immediate_id,
    input wire [4:0] rs1_id,
    input wire [4:0] rs2_id,
    input wire [4:0] rd_id,
    input wire branch_id,
    input wire MemRead_id, MemWrite_id,
    input wire MemtoReg_id, ALUSrc_id, RegWrite_id,
    input wire [1:0] ALUOp_id,
    //Ex
    output reg [31:0]  pc_plus4_ex,
    output reg [31:0]  read_data1_ex,
    output reg [31:0]  read_data2_ex,
    output reg [31:0]  immediate_ex,
    output reg [4:0]   rs1_ex,
    output reg [4:0]   rs2_ex,
    output reg [4:0]   rd_ex,
    // Sinais de controle para EX
    output reg branch_ex,
    output reg MemRead_ex,
    output reg MemtoReg_ex,
    output reg MemWrite_ex,
    output reg ALUSrc_ex,
    output reg RegWrite_ex,
    output reg [1:0] ALUOp_ex
);

    always @(posedge clock or posedge reset) begin
        if (reset) begin
            // Zera todos os valores e sinais de controle em reset
            pc_plus4_ex   <= 32'b0;
            read_data1_ex <= 32'b0;
            read_data2_ex <= 32'b0;
            immediate_ex  <= 32'b0;
            rs1_ex        <= 5'b0;
            rs2_ex        <= 5'b0;
            rd_ex         <= 5'b0;
            branch_ex     <= 1'b0;
            MemRead_ex   <= 1'b0;
            MemtoReg_ex <= 1'b0;
            MemWrite_ex  <= 1'b0;
            ALUSrc_ex    <= 1'b0;
            RegWrite_ex  <= 1'b0;
            ALUOp_ex     <= 2'b0;
        end else begin
            // Passa os valores e sinais para o próximo estágio
            pc_plus4_ex   <= pc_plus4_id;
            read_data1_ex <= read_data1_id;
            read_data2_ex <= read_data2_id;
            immediate_ex  <= immediate_id;
            rs1_ex        <= rs1_id;
            rs2_ex        <= rs2_id;
            rd_ex         <= rd_id;
            branch_ex     <= branch_id;
            MemRead_ex   <= MemRead_id;
            MemtoReg_ex <= MemtoReg_id;
            MemWrite_ex  <= MemWrite_id;
            ALUSrc_ex    <= ALUSrc_id;
            RegWrite_ex  <= RegWrite_id;
            ALUOp_ex     <= ALUOp_id;
        end
    end
endmodule
