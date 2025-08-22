module ex_mem_register (
    input wire         clock, 
    input wire         reset,
    // Entradas do estágio EX
    input wire [31:0]  alu_result_ex,
    input wire [31:0]  read_data2_ex, // Dado a ser escrito na memória (para SW)
    input wire [4:0]   rd_ex,
    input wire [2:0] funct3_ex,
    // Sinais de controle
    input wire         MemRead_ex,
    input wire         MemtoReg_ex,
    input wire         MemWrite_ex,
    input wire         RegWrite_ex,

    // Saídas para o estágio MEM
    output reg [31:0]  alu_result_mem,
    output reg [31:0]  read_data2_mem,
    output reg [4:0]   rd_mem,
    // Sinais de controle para MEM
    output reg         MemRead_mem,
    output reg         MemtoReg_mem,
    output reg         MemWrite_mem,
    output reg         RegWrite_mem,
    output reg [2:0] funct3_mem
);
    always @(posedge clock or posedge reset) begin
        if (reset) begin
            alu_result_mem <= 32'b0;
            read_data2_mem <= 32'b0;
            rd_mem         <= 5'b0;
            MemRead_mem   <= 1'b0;
            MemtoReg_mem <= 1'b0;
            MemWrite_mem  <= 1'b0;
            RegWrite_mem  <= 1'b0;
            funct3_mem <= 3'b0; 
        end else begin
            alu_result_mem <= alu_result_ex;
            read_data2_mem <= read_data2_ex;
            rd_mem         <= rd_ex;
            MemRead_mem   <= MemRead_ex;
            MemtoReg_mem <= MemtoReg_ex;
            MemWrite_mem  <= MemWrite_ex;
            RegWrite_mem  <= RegWrite_ex;
            funct3_mem <= funct3_ex;
        end
    end
endmodule