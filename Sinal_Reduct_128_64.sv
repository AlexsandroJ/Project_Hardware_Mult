module  Sinal_Reduct_128_64(
    input logic [127:0] Entrada_128,
    output logic [63:0] Saida_Hi_128,
    output logic [63:0] Saida_Low_128
);

always_comb begin

    Saida_Hi_128    = {Entrada_128[127:64]};
    Saida_Low_128   = {Entrada_128[63:0]};
    
end
endmodule
