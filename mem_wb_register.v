module mem_wb_register (
    input wire         clock, 
    input wire         reset,
    // Entradas do estágio MEM
    input wire [31:0]  read_data_mem,
    input wire [31:0]  alu_result_mem,
    input wire [4:0]   rd_mem,
    // Sinais de controle
    input wire         MemtoReg_mem,
    input wire         RegWrite_mem,

    // Saídas para o estágio WB
    output reg [31:0]  read_data_wb,
    output reg [31:0]  alu_result_wb,
    output reg [4:0]   rd_wb,
    // Sinais de controle para WB
    output reg         MemtoReg_wb,
    output reg         RegWrite_wb
);
    always @(posedge clock or posedge reset) begin
        if (reset) begin
            read_data_wb  <= 32'b0;
            alu_result_wb <= 32'b0;
            rd_wb         <= 5'b0;
            MemtoReg_wb <= 1'b0;
            RegWrite_wb  <= 1'b0;
        end else begin
            read_data_wb  <= read_data_mem;
            alu_result_wb <= alu_result_mem;
            rd_wb         <= rd_mem;
            MemtoReg_wb <= MemtoReg_mem;
            RegWrite_wb  <= RegWrite_mem;
        end
    end
endmodule