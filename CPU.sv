
module CPU
(	input logic clock, reset,
	output logic [31:0] opcode,
	output logic [63:0] MemOutInst,
    output logic [31:0] rAddressInst,
    output logic [63:0] WriteDataMem,
    output logic [63:0] WriteRegister,
    output logic [63:0] WriteDataReg,
    output logic RegWrite,
    output logic [63:0] MDR,
    output logic [63:0] Alu,
    output logic [63:0] AluOut,
    output logic [63:0] PC_,
    output logic [63:0] DeslocValue,
    output logic wrDataMem,
    output logic wrInstMem,
    output logic IRWrite,
    output logic [63:0] EPC_,
    output logic [4:0] Estado
);
//_________________________________Observacoes______________________________________________|
	// palavras iniciais das variaveis sao o nome do bloco em que ela e usada separada por '_'  |
	// em segida o nome especifico da entrada, o seu objetivo de uso                            |
	// exemplo: "bancoRegisters_Instuction" -> Bloco:"bancoRegisters" Uso: "Instuction"         |
	// se a primeira letra de Uso estiver em maiusculo, siginifica que e um arrey de linhas     |
	// se a primeira letra de Uso estiver em minusculo, siginifica que e um bit                 |
//__________________________________________________________________________________________|

//_________________________________Declarações______________________________________________
	// saidas e controle regiter PC
	wire PC_Write;
	wire [63:0] PC_DadosOut;

	// saidas e controle Memoria de instrucao
	wire Memory_Instruction_write;
	wire [31:0] Memory_Instruction_DataOut;

	// Saidas e controle Memoria de dados
	wire Data_Memory_write;
	wire [63:0] Data_Memory_Out;

	// saidas registrador de dados da memoria
	wire [63:0]Reg_Memory_Data_Out;
	wire Reg_Memory_Data_wr;

	// Saida corte_antes
	wire [63:0]DadoIn_64;

	// Saida corte depois
	wire [63:0]Saida_Memory_Data;

	// saida mux do banco de registrador 
	wire [2:0]	Mux64_Banco_Reg_Seletor;
	wire [63:0]	Mux64_Banco_Reg_Out;

	// saidas e controle registrador de instrucao
	wire Register_Intruction_load_ir;
	wire [4:0] Register_Intruction_Instr19_15;
	wire [4:0] Register_Intruction_Instr24_20;
	wire [4:0] Register_Intruction_Instr11_7;
	wire [6:0] Register_Intruction_Instr6_0;
	wire [31:0] Register_Intruction_Instr31_0;

	// Saida Extensor de Sinal
	wire [63:0] Sinal_Extend_Out;

	// saida Modulo de deslocamento
	wire [63:0]Shift_Left_Out;

	// saidas e controle banco de Registradores
	wire bancoRegisters_write;
	wire [63:0] bancoRegisters_DataOut_1;
	wire [63:0] bancoRegisters_DataOut_2;

	// saidas e controle registrador A
	wire [63:0] Reg_A_Out;
	wire reset_A;
	wire Reg_A_Write;

	// saidas e controle registrador B
	wire [63:0] Reg_B_Out;
	wire Reg_B_Write;

	// saidas e controle Deslocamento Funcional
	wire [1:0]Shift_Control;
	wire [63:0]Shift_Funcional_Out;

	// saidas e controle Mux A
	wire [2:0] Mux64_Ula_A_Seletor;
	wire [63:0] Mux64_Ula_A_Out;

	// saidas e controle Mux B
	wire [2:0] Mux64_Ula_B_Seletor;
	wire [63:0] Mux64_Ula_B_Out;

	// saidas e controle Da ULA
	wire [63:0] A;
	wire [63:0] B;
	wire [63:0] S;
	wire [2:0] Seletor;
	wire overFlow;
	wire negativo;
	wire z;
	wire igual;
	wire maior;
	wire menor;

	// saidas registrador da saida da ula
	wire [63:0]Reg_ULAOut_Out;
	wire Reg_ULAOut_Write;

	// Outros Fios usados
	wire load_ir;

	// saidas e controle EPC
	wire EPC_wr;
	wire [63:0] EPC_Out;

	// saidas e Registrador de causa
	wire Reg_Causa_wr;
	wire [63:0] Reg_Causa_Out;
	wire [63:0] Reg_Causa_Dados_In;

	// Saida Estensor de sinal 8 para 32
	wire [63:0] Saida_Extend_8_32_Out;

	// Saida e controle Mux da entrada de PC para estensao de sinal
	wire [63:0] Mux64_PC_Extend_Out;
	wire [2:0] Mux64_PC_Extend_Seletor;

	// Debugar codigo
	wire [4:0]Situacao;
	wire desgraca;

//_________________________________Atualizacao para 128 bits _________________________________________
	// Saida Estensor de sinal 64 para 128
	wire [127:0] Saida_Extend_64_128_Out;
	// Saida e controle Mux da entrada de C para ULA de 128 bits
	wire [127:0] Mux_128_C_Out;
	wire [2:0] Mux_128_C_Seletor;
	// saidas e Registrador de C
	wire Reg_C_wr;
	wire [127:0] Reg_C_Out;
	// saidas e Registrador de Soma
	wire Reg_Soma_wr;
	wire [127:0] Reg_Soma_Out;
	// Saida Shift de 1 bit com entrada e saida de 128 bits
	wire [127:0] Shift_C_Out_128;
	// saidas e controle Da ULA 128 bits
	wire [127:0] S_Ula_128;
	wire [2:0] Seletor_Ula_128;
	wire overFlow_Ula_128;
	wire negativo_Ula_128;
	wire z_Ula_128;
	wire igual_Ula_128;
	wire maior_Ula_128;
	wire menor_Ula_128;
	// Saida Separador Hi Low para instrucao de multiplicacao
	wire [63:0] Hi_64;
	wire [63:0] Low_64;
	// Saidas e controle Mux de saida da ula 64 atualizada para multiplicaco
	wire [63:0] Mux_64_Hi_Low_Out;
	wire [2:0] Mux_64_Hi_Low_Seletor;

//____________________________________________________________________________________________________
//_________________________________saidas da Unidade de Controle______________________________________
//					PC_Write								: grava em PC
//					Seletor_Ula 							: 3 Bits seleciona a operacao na ula
//					Mux64_Ula_A_Seletor						: 3 Bits
//					Mux64_Ula_B_Seletor						: 3 Bits
//					load_ir									: escrita no registrador de instrucao
//					Data_Memory_write						: leitura ou Escrita na Memoria
//					bancoRegisters_write					: escrita em regwriteaddress
//					Mux64_Banco_Reg_Seletor					: 3 Bits
//					reset_A									: zera registrador A
//_____________________________________________________________________________________________________
//_________________________________________Unidade de Controle_________________________________________
	UC UC_(								.clock(											clock						),
										.Register_Intruction_Instr31_0(					Register_Intruction_Instr31_0),
										.multiplicador(									bancoRegisters_DataOut_2	),
										.reset(											reset						),
										.PC_Write(										PC_Write					),
										.Seletor_Ula(									Seletor						),
										.Load_ir(										load_ir						),
										.mux_A_seletor(									Mux64_Ula_A_Seletor			),
    									.mux_B_seletor(									Mux64_Ula_B_Seletor			),
										.Data_Memory_wr(								Data_Memory_write			),
										.bancoRegisters_wr(								bancoRegisters_write		),
										.Mux_Banco_Reg_Seletor(							Mux64_Banco_Reg_Seletor		),
										.z(		                    					z							),
										.igual(		               						igual						),
										.maior(		               						maior						),
										.menor(		                					menor						),
										.overFlow(										overFlow					),
										.reset_A( 										reset_A						),
										.Shift_Control(									Shift_Control				),
										.Reg_A_Write( 									Reg_A_Write					),
										.Reg_B_Write( 									Reg_B_Write					),
										.Situacao(										Situacao					),
										.Reg_Memory_Data_wr(							Reg_Memory_Data_wr			),
										.EPC_wr(										EPC_wr						),
										.Reg_Causa_wr(									Reg_Causa_wr				),
										.Reg_Causa_Dados_In(							Reg_Causa_Dados_In			),
										.flag_overFlow(									desgraca					),		
										.Mux64_PC_Extend_Seletor(						Mux64_PC_Extend_Seletor		),
										.Mux_Seletor_C_In_128(							Mux_128_C_Seletor			),
										.C_wr(											Reg_C_wr					),
										.Soma_wr(										Reg_Soma_wr					),
										.Mux_Seletor_Mux_Hi_Low(						Mux_64_Hi_Low_Seletor		),
										.Seletor_Ula_128(								Seletor_Ula_128				)
																													);
//_____________________________________________________________________________________________________
//_________________________________________Registrador PC [In 64 Bits ] [Out 32 Bits ]_________________
	register PC( 						.clk(					clock									), 
										.reset(					reset									), 
										.regWrite(				PC_Write								), 
										.DadoIn(				Mux64_PC_Extend_Out						), 
										.DadoOut(				PC_DadosOut								)
																										);
//_____________________________________________________________________________________________________
//_________________________________________Memoria De Instrucao 32 Bits________________________________
	Memoria32 Memory_Instruction( 			
										.raddress(				PC_DadosOut[31:0]						), 
										.waddress(				32'd0									), 
										.Clk(					clock									), 
										.Datain(				32'd0									), 
										.Dataout(				Memory_Instruction_DataOut				), 
										.Wr(					1'd0									)
																										);															
//_____________________________________________________________________________________________________
//_________________________________________Diminuição do rd antes______________________________________
	Battousai_Store corte_antes( 		
										.Reg_B_Out(								Reg_B_Out				), //INPUT
										.Mem64_Out(								Data_Memory_Out			),
										.Register_Intruction_Instr31_0(			Register_Intruction_Instr31_0		), 
										.DadoIn_64(								DadoIn_64				)
																										);	
//_____________________________________________________________________________________________________
//_________________________________________Memoria de Dados 64 Bits____________________________________
	Memoria64 Data_Memory( 			
										.raddress(								S						), 
										.waddress(								S						), 
										.Clk(									clock					), 
										.Datain(								DadoIn_64				), 
										.Dataout(								Data_Memory_Out			), 
										.Wr(									Data_Memory_write		)
																										);
//_____________________________________________________________________________________________________
//_________________________________________Diminuição do rd depois_____________________________________
	Battousai_Load corte_depois( 		
										.Dataout(								Data_Memory_Out			), //INPUT
										.Register_Intruction_Instr31_0(			Register_Intruction_Instr31_0			), 
										.Saida_Memory_Data(						Saida_Memory_Data		)
																										);	
//_____________________________________________________________________________________________________
//_________________________________________Registrador de Memoria de Dados 64 Bits_____________________
	register Reg_Memory_Data( 			.clk(									clock					), 
										.reset(									reset					), 
										.regWrite(								Reg_Memory_Data_wr		), 
										.DadoIn(								Saida_Memory_Data		), 
										.DadoOut(								Reg_Memory_Data_Out		)
																										);	
//_____________________________________________________________________________________________________
//_________________________________________Mux 64 Bits da Entrada do banco de registradores____________
	mux64 Mux64_Banco_Reg(				.Seletor(					Mux64_Banco_Reg_Seletor				),
										.A(							S									),
										.B(							Reg_Memory_Data_Out					),
										.C(							Mux_64_Hi_Low_Out					),
										.D(							64'd666								),
										.Saida(						Mux64_Banco_Reg_Out					)
																										);																								
//_____________________________________________________________________________________________________
//_________________________________________Registrador de Instruções 32 Bits___________________________
  Instr_Reg_RISC_V Register_Intruction(	.Clk(						clock								), 
										.Reset(						reset								), 
										.Load_ir(					load_ir								), 
										.Entrada(					Memory_Instruction_DataOut			), 
										.Instr19_15(				Register_Intruction_Instr19_15 		), 
										.Instr24_20(				Register_Intruction_Instr24_20		),
										.Instr11_7(					Register_Intruction_Instr11_7		), 
										.Instr6_0(					Register_Intruction_Instr6_0		), 
										.Instr31_0(					Register_Intruction_Instr31_0		)
																										);

//_____________________________________________________________________________________________________
//_________________________________________Extensao de sinal___________________________________________
	Sinal_Extend Sinal_Extend_(			.Sinal_In(					Register_Intruction_Instr31_0		),
										.Sinal_Out(					Sinal_Extend_Out					)
																										);
//_____________________________________________________________________________________________________
//_________________________________________Delocamento de 1 Bit________________________________________
	Deslocamento Shift_Left(			.Shift(						2'd0								),
										.Entrada(					Sinal_Extend_Out					),
										.N(							6'd1								),
										.Saida(						Shift_Left_Out						)
																										);
//_____________________________________________________________________________________________________
//_________________________________________Banco de registradores 64 Bits______________________________
	bancoReg bancoRegisters( 			.write(						bancoRegisters_write				),
										.clock(						clock								),
										.reset(						reset								),
										.regreader1(				Register_Intruction_Instr19_15		),
									  	.regreader2(				Register_Intruction_Instr24_20		),
									   	.regwriteaddress(			Register_Intruction_Instr11_7		),
									  	.datain(					Mux64_Banco_Reg_Out					),
										.dataout1(					bancoRegisters_DataOut_1			),
									   	.dataout2(					bancoRegisters_DataOut_2			)			
																										);
//_____________________________________________________________________________________________________
//_________________________________________Delocamento de N Bits_______________________________________
	Deslocamento deslocador_funcional(	.Shift(						Shift_Control						),
										.Entrada(					bancoRegisters_DataOut_1			),
										.N(							Register_Intruction_Instr31_0[25:20]),
										.Saida(						Shift_Funcional_Out					)
																										);
//_____________________________________________________________________________________________________
//_________________________________________Registrador A 64 Bits_______________________________________
	register Reg_A( 					.clk(						clock								), 
										.reset(						reset_A								), 
										.regWrite(					Reg_A_Write							), 
										.DadoIn(					Shift_Funcional_Out					), 
										.DadoOut(					Reg_A_Out							)
																										);
//_____________________________________________________________________________________________________
//_________________________________________Registrador B 64 Bits_______________________________________
	register Reg_B( 					.clk(						clock								), 
										.reset(						reset								), 
										.regWrite(					Reg_B_Write							), 
										.DadoIn(					bancoRegisters_DataOut_2			), 
										.DadoOut(					Reg_B_Out							)
																										);
//_____________________________________________________________________________________________________									
//_________________________________________Mux Entrada A da Ula A 64 Bits _____________________________
	mux64 Mux64_Ula_A(					.Seletor(					Mux64_Ula_A_Seletor					),
										.A(							PC_DadosOut							),
										.B(							Reg_A_Out							),
										.C(							64'd254								),
										.D(							64'd255								),
										.Saida(						Mux64_Ula_A_Out						)
																										);											  
//_____________________________________________________________________________________________________	
//_________________________________________Mux Entrada B da Ula A 64 Bits _____________________________
	mux64 Mux64_Ula_B(					.Seletor(					Mux64_Ula_B_Seletor					),
										.A(							Reg_B_Out							),
										.B(							64'd4								),
										.C(							Sinal_Extend_Out					),
										.D(							Shift_Left_Out						),
										.Saida(						Mux64_Ula_B_Out						)
																										);	
//_____________________________________________________________________________________________________	
//_________________________________________Ula_________________________________________________________
	ula64 ULA( 							.A(							Mux64_Ula_A_Out						),
										.B( 						Mux64_Ula_B_Out						), 
										.Seletor(					Seletor								), 
										.S(							S									), 
										.overFlow(					overFlow							), 
										.negativo(					negativo							), 
										.z(							z									), 
										.igual(						igual								), 
										.maior(						maior								), 
										.menor(						menor								)
																										);
//_____________________________________________________________________________________________________
//_________________________________________Registrador Saida da Ula____________________________________
	register Reg_ULAOut( 				.clk(						clock								), 
										.reset(						reset								), 
										.regWrite(					1'd1								), 
										.DadoIn(					S									), 
										.DadoOut(					Reg_ULAOut_Out						)
																										);
//_____________________________________________________________________________________________________									
//_________________________________________Mux Entrada de PC 64 Bits __________________________________
	mux64 Mux64_PC_Exctend(				.Seletor(					Mux64_PC_Extend_Seletor				),
										.A(							S									),
										.B(							Saida_Extend_8_32_Out				),
										.C(							EPC_Out								),
										.D(							64'd666								),
										.Saida(						Mux64_PC_Extend_Out					)
																										);	
//_____________________________________________________________________________________________________
//_________________________________________Estensao de sinal para Excecao 64 Bits _____________________
	Sinal_Extend_8_32 Sina_8_32(		.causa(						Reg_Causa_Dados_In[1:0]				),
										.Entrada_8_bits(			Memory_Instruction_DataOut			),
										.Saida_32(					Saida_Extend_8_32_Out				)
																										);
//_____________________________________________________________________________________________________
//_________________________________________Registrador EPC que recebe a instrucao da Excesao___________
	register EPC( 						.clk(						clock								), 
										.reset(						reset								), 
										.regWrite(					EPC_wr								), 
										.DadoIn(					Reg_ULAOut_Out						), 
										.DadoOut(					EPC_Out								)
																										);
//_____________________________________________________________________________________________________
//_________________________________________Registrador que Guarda a causa da Excesao PC 64 Bits _______
	register Reg_Causa( 				.clk(						clock								), 
										.reset(						reset								), 
										.regWrite(					Reg_Causa_wr						), 
										.DadoIn(					Reg_Causa_Dados_In					), 
										.DadoOut(					Reg_Causa_Out						)
																										);
//_____________________________________________________________________________________________________
//######################################## Atualizacao para 128Bits ###################################
//_________________________________________Extensao de sinal de 64 para 128 Bits ______________________
	Sinal_Extend_64_128 Sinal_64_128(	.Entrada_64(				bancoRegisters_DataOut_1			),
										.Saida_128(					Saida_Extend_64_128_Out				)
																										);
//_____________________________________________________________________________________________________
//_________________________________________Mux Entrada de C 128 Bits __________________________________
	mux_128 Mux_C_In_128(				.Seletor(					Mux_128_C_Seletor					),
										.A(							Saida_Extend_64_128_Out				),
										.B(							Shift_C_Out_128						),
										.C(							128'd666							),
										.D(							128'd666							),
										.Saida(						Mux_128_C_Out						)
																										);	
//_____________________________________________________________________________________________________
//_________________________________________Shift de 1 Bit com entrada e saida de 128 bits______________
	Shift_1_bit_In_Out_128_bit Shift_C(	.Entrada(					Reg_C_Out							),
										.Saida(						Shift_C_Out_128						)
																										);
//_____________________________________________________________________________________________________
//_________________________________________Registrador C ______________________________________________
	register_128bits Reg_C( 			.clk(						clock								), 
										.reset(						reset								), 
										.regWrite(					Reg_C_wr							), 
										.DadoIn(					Mux_128_C_Out						), 
										.DadoOut(					Reg_C_Out							)
																										);
//_____________________________________________________________________________________________________
//_________________________________________Registrador Soma ___________________________________________
	register_128bits Soma( 				.clk(						clock								), 
										.reset(						reset								), 
										.regWrite(					Reg_Soma_wr							), 
										.DadoIn(					S_Ula_128							), 
										.DadoOut(					Reg_Soma_Out						)
																										);
//_____________________________________________________________________________________________________
//_________________________________________Ula 128 bits________________________________________________
	Ula_128 Ula_para_mult_128_bits( 	.A(							Reg_C_Out							),
										.B( 						Reg_Soma_Out						), 
										.Seletor(					Seletor_Ula_128						), 
										.S(							S_Ula_128							), 
										.overFlow(					overFlow_Ula_128					), 
										.negativo(					negativo_Ula_128					), 
										.z(							z_Ula_128							), 
										.igual(						igual_Ula_128						), 
										.maior(						maior_Ula_128						), 
										.menor(						menor_Ula_128						)
																										);
//_____________________________________________________________________________________________________
//_________________________________________Separador Hi_Low____________________________________________
	Sinal_Reduct_128_64 Separador_Hi_Low ( 	.Entrada_128(			S_Ula_128							), 
											.Saida_Hi_128(			Hi_64								), 
											.Saida_Low_128(			Low_64								) 
																										);
//_____________________________________________________________________________________________________
//_________________________________________Mux Entrada B da Ula A 64 Bits _____________________________
	mux64 Mux64_Hi_Low(					.Seletor(					Mux_64_Hi_Low_Seletor				),
										.A(							Low_64								),
										.B(							Hi_64								),
										.C(							64'd666								),
										.D(							64'd666								),
										.Saida(						Mux_64_Hi_Low_Out					)
																										);	
//_____________________________________________________________________________________________________	


	always_comb begin
	
	  	opcode 					<= Register_Intruction_Instr6_0;

		MemOutInst 				<= Memory_Instruction_DataOut;
		rAddressInst 			<= PC_DadosOut;
		WriteDataMem			<= DadoIn_64;
		WriteRegister			<= Register_Intruction_Instr11_7;
		WriteDataReg			<= Mux64_Banco_Reg_Out;
		RegWrite				<= bancoRegisters_write;
		MDR 					<= Reg_Memory_Data_Out;
		Alu						<= S;
		AluOut					<= Reg_ULAOut_Out;
		PC_						<= PC_DadosOut;
		DeslocValue				<= Sinal_Extend_Out;
		wrDataMem				<= Data_Memory_write;
		wrInstMem				<= 1'd0;
		IRWrite					<= load_ir;
		EPC_					<= EPC_Out;
		Estado 					<= Situacao;

    end

endmodule

