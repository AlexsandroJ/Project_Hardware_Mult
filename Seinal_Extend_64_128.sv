module  Sinal_Extend_64_128(
    input logic [63:0] Entrada_64,
    output logic [127:0] Saida_128
);

always_comb begin

    Saida_128 = {64'd0, Entrada_64};
    
end
endmodule
