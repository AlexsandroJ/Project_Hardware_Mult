module Shift_1_bit_In_Out_128_bit (	
					input logic [127:0] Entrada,
					output logic [127:0]Saida
					);

always_comb
	
	Saida = Entrada << 1;
		
endmodule