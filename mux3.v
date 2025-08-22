module mux3 #(parameter WIDTH = 32) (
    input wire [1:0]       seletor,
    input wire [WIDTH-1:0] entrada1,  // Selecionado por 2'b00
    input wire [WIDTH-1:0] entrada2,  // Selecionado por 2'b01
    input wire [WIDTH-1:0] entrada3,  // Selecionado por 2'b10
    output reg [WIDTH-1:0] saida
);
    always @(*) begin
        case (seletor)
            2'b00:   saida = entrada1;
            2'b01:   saida = entrada2;
            2'b10:   saida = entrada3;
            default: saida = {WIDTH{1'bx}}; // Saída indefinida para seletores não utilizados
        endcase
    end
endmodule