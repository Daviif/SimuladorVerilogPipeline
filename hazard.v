module hazard (
    // Entradas
    input wire [4:0] rs1_id,      // rs1 da instrução no estágio ID
    input wire [4:0] rs2_id,      // rs2 da instrução no estágio ID
    input wire [4:0] rd_ex,       // rd da instrução no estágio EX
    input wire  MemRead_ex, // Indica se a instrução em EX é um load
    
    // Saídas
    output reg pc_write,    // Habilita a escrita no PC
    output reg if_id_write, // Habilita a escrita no registrador IF/ID
    output reg flush_id_ex  // Sinal para zerar os controles no registrador ID/EX (inserir nop)
);
    always @(*) begin
        // Valores padrão (sem hazard)
        pc_write = 1'b1;
        if_id_write = 1'b1;
        flush_id_ex = 1'b0;

        // Detecção de Hazard de Load-Use:
        // Se a instrução no estágio EX é um load (MemRead = 1) E
        // o seu registrador de destino (rd_ex) é um dos fontes (rs1_id ou rs2_id)
        // da instrução no estágio ID, então um stall é necessário.
        if (MemRead_ex && (rd_ex != 5'b0) && ((rd_ex == rs1_id) || (rd_ex == rs2_id))) begin
            pc_write = 1'b0;      // Congela o PC
            if_id_write = 1'b0;   // Congela o registrador IF/ID
            flush_id_ex = 1'b1;   // Insere uma bolha (nop) no próximo estágio
        end
    end
endmodule