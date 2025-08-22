module forwarding_unit (
    input wire [4:0] rs1_ex,         // Endereço do registrador rs1 no estágio EX
    input wire [4:0] rs2_ex,         // Endereço do registrador rs2 no estágio EX
    input wire [4:0] rd_mem,         // Endereço de destino no estágio MEM
    input wire [4:0] rd_wb,          // Endereço de destino no estágio WB
    input wire       RegWrite_mem,  // Sinal de escrita do estágio MEM
    input wire       RegWrite_wb,   // Sinal de escrita do estágio WB
    output reg [1:0] forwardA,       // Controle do MUX para a entrada A da ALU
    output reg [1:0] forwardB        // Controle do MUX para a entrada B da ALU
);
    always @(*) begin
        forwardA = 2'b00;
        forwardB = 2'b00;
        // --- Lógica para a entrada A (rs1) ---
        // Hazard EX/MEM: Se a instrução no estágio MEM está escrevendo no registrador que rs1 precisa ler
        if (RegWrite_mem && (rd_mem != 5'b0) && (rd_mem == rs1_ex)) begin
            forwardA = 2'b10;
        // Hazard MEM/WB: Se a instrução no estágio WB está escrevendo no registrador que rs1 precisa ler
        // (e não há um hazard EX/MEM mais recente para o mesmo registrador)
        end else if (RegWrite_wb && (rd_wb != 5'b0) && (rd_wb == rs1_ex)) begin
            forwardA = 2'b01;
        end else begin
            forwardA = 2'b00; // Sem forwarding
        end

        // --- Lógica para a entrada B (rs2) ---
        // Hazard EX/MEM
        if (RegWrite_mem && (rd_mem != 5'b0) && (rd_mem == rs2_ex)) begin
            forwardB = 2'b10;
        // Hazard MEM/WB
        end else if (RegWrite_wb && (rd_wb != 5'b0) && (rd_wb == rs2_ex)) begin
            forwardB = 2'b01;
        end else begin
            forwardB = 2'b00; // Sem forwarding
        end
    end
endmodule