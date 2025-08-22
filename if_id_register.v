module if_id_register(
    input wire clock,
    input wire reset,
    input wire stall,
    input wire flush,
    input wire [31:0] pc_plus4_if,
    input wire [31:0] instrucao_if,
    output reg [31:0] pc_plus4_id,
    output reg [31:0] instrucao_id
);

    always @(posedge clock or posedge reset) begin
        if (reset || flush) begin
            pc_plus4_id <= 32'b0;
            instrucao_id <= 32'b0;
        end else if (!stall) begin
            pc_plus4_id <= pc_plus4_if;
            instrucao_id <= instrucao_if;
        end
    end
endmodule