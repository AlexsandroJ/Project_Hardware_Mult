--------------------------------------------------------------------------------
-- Title		: Unidade de L�gica e Aritm�tica
-- Project		: CPU multi-ciclo
--------------------------------------------------------------------------------
-- File			: ula32.vhd
-- Author		: Emannuel Gomes Mac�do (egm@cin.ufpe.br)
--				  Fernando Raposo Camara da Silva (frcs@cin.ufpe.br)
--				  Pedro Machado Manh�es de Castro (pmmc@cin.ufpe.br)
--				  Rodrigo Alves Costa (rac2@cin.ufpe.br)
-- Organization : Universidade Federal de Pernambuco
-- Created		: 29/07/2002
-- Last update	: 21/11/2002
-- Plataform	: Flex10K
-- Simulators	: Altera Max+plus II
-- Synthesizers	: 
-- Targets		: 
-- Dependency	: 
--------------------------------------------------------------------------------
-- Description	: Entidade que processa as opera��es l�gicas e aritm�ticas da
-- cpu.
--------------------------------------------------------------------------------
-- Copyright (c) notice
--		Universidade Federal de Pernambuco (UFPE).
--		CIn - Centro de Informatica.
--		Developed by computer science undergraduate students.
--		This code may be used for educational and non-educational purposes as 
--		long as its copyright notice remains unchanged. 
--------------------------------------------------------------------------------
-- Revisions		: 1
-- Revision Number	: 1
-- Version			: 1.1
-- Date				: 21/11/2002
-- Modifier			: Marcus Vinicius Lima e Machado (mvlm@cin.ufpe.br)
--				   	  Paulo Roberto Santana Oliveira Filho (prsof@cin.ufpe.br)
--					  Viviane Cristina Oliveira Aureliano (vcoa@cin.ufpe.br)
-- Description		:
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Revisions		: 2
-- Revision Number	: 1.1
-- Version			: 1.2
-- Date				: 18/08/2008
-- Modifier			: Jo�o Paulo Fernandes Barbosa (jpfb@cin.ufpe.br)
-- Description		: Entradas, sa�das e sinais internos passam a ser std_logic.
--------------------------------------------------------------------------------



LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;

-- Short name: ula
entity Ula_128 is
	port ( 
		A 			: in  std_logic_vector (127 downto 0);	-- Operando A da ULA
		B 			: in  std_logic_vector (127 downto 0);	-- Operando B da ULA
		Seletor 	: in  std_logic_vector (2 downto 0);	-- Seletor da opera��o da ULA
		S 			: out std_logic_vector (127 downto 0);	-- Resultado da opera��o (SOMA, SUB, AND, NOT, INCREMENTO, XOR)  
		Overflow 	: out std_logic;						-- Sinaliza overflow aritm�tico
		Negativo	: out std_logic;						-- Sinaliza valor negativo
		z 			: out std_logic;						-- Sinaliza quando S for zero
		Igual		: out std_logic;						-- Sinaliza se A=B
		Maior		: out std_logic;						-- Sinaliza se A>B
		Menor		: out std_logic 						-- Sinaliza se A<B
	);
end Ula_128;

-- Simulation
architecture behavioral of Ula_128 is
	
	signal s_temp		: std_logic_vector (127 downto 0);	-- Sinal que recebe valor tempor�rio da opera��o realizada
 	signal soma_temp 	: std_logic_vector (127 downto 0);   -- Sinal que recebe o valor temporario da soma, subtra��o ou incremento
	signal carry_temp	: std_logic_vector (127 downto 0);   -- Vetor para aux�lio no c�lculo das opera��es e do overflow aritm�tico 
	signal novo_B 		: std_logic_vector (127 downto 0);   -- Vetor que fornece o operando B, 1 ou not(B) para opera��es de soma, incremento ou subtra��o respectivamente
	signal i_temp		: std_logic_vector (127 downto 0);   -- Vetor para calculo de incremento
	signal igual_temp	: std_logic;						-- Bit que armazena instancia tempor�ria de igualdade
	signal overflow_temp: std_logic;						-- Bit que armazena valor tempor�rio do overflow

	begin

		with Seletor select
	
			s_temp <= 	A  			when "000", -- LOAD
			  			soma_temp  	when "001",	-- SOMA
			  			soma_temp   when "010",	-- SUB
			  			(A and B)  	when "011",	-- AND
			  			(A xor B) 	when "110", -- A XOR B              
              			not(A)     	when "101",	-- NOT A
			  			soma_temp  	when "100",	-- INCREMENTO			  
             			"00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" when others;  	-- NAO DEFINIDO
			
			S <= s_temp;
			
			Negativo <= s_temp(31);
			
			i_temp <= "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001";
			
			z <= '1' when s_temp = "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" else '0';

--------------------------------------------------------------------------------
--		Regiao que calcula a soma, subtracao e incremento					  --	
--------------------------------------------------------------------------------
		with Seletor select
    		
			novo_B <= B  		when "001",  -- Soma
   				      i_temp 	when "100",  -- Incremento
                      not(B) 	when others; -- Subtracao e outros	
  	
    		soma_temp(0) <= A(0) xor novo_B(0) xor seletor(1);
			soma_temp(1) <= A(1) xor novo_B(1) xor carry_temp(0);
			soma_temp(2) <= A(2) xor novo_B(2) xor carry_temp(1);
			soma_temp(3) <= A(3) xor novo_B(3) xor carry_temp(2);
			soma_temp(4) <= A(4) xor novo_B(4) xor carry_temp(3);
			soma_temp(5) <= A(5) xor novo_B(5) xor carry_temp(4);
			soma_temp(6) <= A(6) xor novo_B(6) xor carry_temp(5);
			soma_temp(7) <= A(7) xor novo_B(7) xor carry_temp(6);
			soma_temp(8) <= A(8) xor novo_B(8) xor carry_temp(7);
			soma_temp(9) <= A(9) xor novo_B(9) xor carry_temp(8);
			soma_temp(10) <= A(10) xor novo_B(10) xor carry_temp(9);
			soma_temp(11) <= A(11) xor novo_B(11) xor carry_temp(10);
			soma_temp(12) <= A(12) xor novo_B(12) xor carry_temp(11);
			soma_temp(13) <= A(13) xor novo_B(13) xor carry_temp(12);
			soma_temp(14) <= A(14) xor novo_B(14) xor carry_temp(13);
			soma_temp(15) <= A(15) xor novo_B(15) xor carry_temp(14);
			soma_temp(16) <= A(16) xor novo_B(16) xor carry_temp(15);
			soma_temp(17) <= A(17) xor novo_B(17) xor carry_temp(16);
			soma_temp(18) <= A(18) xor novo_B(18) xor carry_temp(17);
			soma_temp(19) <= A(19) xor novo_B(19) xor carry_temp(18);
			soma_temp(20) <= A(20) xor novo_B(20) xor carry_temp(19);
			soma_temp(21) <= A(21) xor novo_B(21) xor carry_temp(20);
			soma_temp(22) <= A(22) xor novo_B(22) xor carry_temp(21);
			soma_temp(23) <= A(23) xor novo_B(23) xor carry_temp(22);
			soma_temp(24) <= A(24) xor novo_B(24) xor carry_temp(23);
			soma_temp(25) <= A(25) xor novo_B(25) xor carry_temp(24);
			soma_temp(26) <= A(26) xor novo_B(26) xor carry_temp(25);
			soma_temp(27) <= A(27) xor novo_B(27) xor carry_temp(26);
			soma_temp(28) <= A(28) xor novo_B(28) xor carry_temp(27);
			soma_temp(29) <= A(29) xor novo_B(29) xor carry_temp(28);
			soma_temp(30) <= A(30) xor novo_B(30) xor carry_temp(29);
			soma_temp(31) <= A(31) xor novo_B(31) xor carry_temp(30);
			soma_temp(32) <= A(32) xor novo_B(32) xor carry_temp(31);
			soma_temp(33) <= A(33) xor novo_B(33) xor carry_temp(32);
			soma_temp(34) <= A(34) xor novo_B(34) xor carry_temp(33);
			soma_temp(35) <= A(35) xor novo_B(35) xor carry_temp(34);
			soma_temp(36) <= A(36) xor novo_B(36) xor carry_temp(35);
			soma_temp(37) <= A(37) xor novo_B(37) xor carry_temp(36);
			soma_temp(38) <= A(38) xor novo_B(38) xor carry_temp(37);
			soma_temp(39) <= A(39) xor novo_B(39) xor carry_temp(38);
			soma_temp(40) <= A(40) xor novo_B(40) xor carry_temp(39);
			soma_temp(41) <= A(41) xor novo_B(41) xor carry_temp(40);
			soma_temp(42) <= A(42) xor novo_B(42) xor carry_temp(41);
			soma_temp(43) <= A(43) xor novo_B(43) xor carry_temp(42);
			soma_temp(44) <= A(44) xor novo_B(44) xor carry_temp(43);
			soma_temp(45) <= A(45) xor novo_B(45) xor carry_temp(44);
			soma_temp(46) <= A(46) xor novo_B(46) xor carry_temp(45);
			soma_temp(47) <= A(47) xor novo_B(47) xor carry_temp(46);
			soma_temp(48) <= A(48) xor novo_B(48) xor carry_temp(47);
			soma_temp(49) <= A(49) xor novo_B(49) xor carry_temp(48);
			soma_temp(50) <= A(50) xor novo_B(50) xor carry_temp(49);
			soma_temp(51) <= A(51) xor novo_B(51) xor carry_temp(50);
			soma_temp(52) <= A(52) xor novo_B(52) xor carry_temp(51);
			soma_temp(53) <= A(53) xor novo_B(53) xor carry_temp(52);
			soma_temp(54) <= A(54) xor novo_B(54) xor carry_temp(53);
			soma_temp(55) <= A(55) xor novo_B(55) xor carry_temp(54);
			soma_temp(56) <= A(56) xor novo_B(56) xor carry_temp(55);
			soma_temp(57) <= A(57) xor novo_B(57) xor carry_temp(56);
			soma_temp(58) <= A(58) xor novo_B(58) xor carry_temp(57);
			soma_temp(59) <= A(59) xor novo_B(59) xor carry_temp(58);
			soma_temp(60) <= A(60) xor novo_B(60) xor carry_temp(59);
			soma_temp(61) <= A(61) xor novo_B(61) xor carry_temp(60);
			soma_temp(62) <= A(62) xor novo_B(62) xor carry_temp(61);
			soma_temp(63) <= A(63) xor novo_B(63) xor carry_temp(62);
			soma_temp(64) <= A(64) xor novo_B(64) xor carry_temp(63);
			soma_temp(65) <= A(65) xor novo_B(65) xor carry_temp(64);
			soma_temp(66) <= A(66) xor novo_B(66) xor carry_temp(65);
			soma_temp(67) <= A(67) xor novo_B(67) xor carry_temp(66);
			soma_temp(68) <= A(68) xor novo_B(68) xor carry_temp(67);
			soma_temp(69) <= A(69) xor novo_B(69) xor carry_temp(68);
			soma_temp(70) <= A(70) xor novo_B(70) xor carry_temp(69);
			soma_temp(71) <= A(71) xor novo_B(71) xor carry_temp(70);
			soma_temp(72) <= A(72) xor novo_B(72) xor carry_temp(71);
			soma_temp(73) <= A(73) xor novo_B(73) xor carry_temp(72);
			soma_temp(74) <= A(74) xor novo_B(74) xor carry_temp(73);
			soma_temp(75) <= A(75) xor novo_B(75) xor carry_temp(74);
			soma_temp(76) <= A(76) xor novo_B(76) xor carry_temp(75);
			soma_temp(77) <= A(77) xor novo_B(77) xor carry_temp(76);
			soma_temp(78) <= A(78) xor novo_B(78) xor carry_temp(77);
			soma_temp(79) <= A(79) xor novo_B(79) xor carry_temp(78);
			soma_temp(80) <= A(80) xor novo_B(80) xor carry_temp(79);
			soma_temp(81) <= A(81) xor novo_B(81) xor carry_temp(80);
			soma_temp(82) <= A(82) xor novo_B(82) xor carry_temp(81);
			soma_temp(83) <= A(83) xor novo_B(83) xor carry_temp(82);
			soma_temp(84) <= A(84) xor novo_B(84) xor carry_temp(83);
			soma_temp(85) <= A(85) xor novo_B(85) xor carry_temp(84);
			soma_temp(86) <= A(86) xor novo_B(86) xor carry_temp(85);
			soma_temp(87) <= A(87) xor novo_B(87) xor carry_temp(86);
			soma_temp(88) <= A(88) xor novo_B(88) xor carry_temp(87);
			soma_temp(89) <= A(89) xor novo_B(89) xor carry_temp(88);
			soma_temp(90) <= A(90) xor novo_B(90) xor carry_temp(89);
			soma_temp(91) <= A(91) xor novo_B(91) xor carry_temp(90);
			soma_temp(92) <= A(92) xor novo_B(92) xor carry_temp(91);
			soma_temp(93) <= A(93) xor novo_B(93) xor carry_temp(92);
			soma_temp(94) <= A(94) xor novo_B(94) xor carry_temp(93);
			soma_temp(95) <= A(95) xor novo_B(95) xor carry_temp(94);
			soma_temp(96) <= A(96) xor novo_B(96) xor carry_temp(95);
			soma_temp(97) <= A(97) xor novo_B(97) xor carry_temp(96);
			soma_temp(98) <= A(98) xor novo_B(98) xor carry_temp(97);
			soma_temp(99) <= A(99) xor novo_B(99) xor carry_temp(98);
			soma_temp(100) <= A(100) xor novo_B(100) xor carry_temp(99);
			soma_temp(101) <= A(101) xor novo_B(101) xor carry_temp(100);
			soma_temp(102) <= A(102) xor novo_B(102) xor carry_temp(101);
			soma_temp(103) <= A(103) xor novo_B(103) xor carry_temp(102);
			soma_temp(104) <= A(104) xor novo_B(104) xor carry_temp(103);
			soma_temp(105) <= A(105) xor novo_B(105) xor carry_temp(104);
			soma_temp(106) <= A(106) xor novo_B(106) xor carry_temp(105);
			soma_temp(107) <= A(107) xor novo_B(107) xor carry_temp(106);
			soma_temp(108) <= A(108) xor novo_B(108) xor carry_temp(107);
			soma_temp(109) <= A(109) xor novo_B(109) xor carry_temp(108);
			soma_temp(110) <= A(110) xor novo_B(110) xor carry_temp(109);
			soma_temp(111) <= A(111) xor novo_B(111) xor carry_temp(110);
			soma_temp(112) <= A(112) xor novo_B(112) xor carry_temp(111);
			soma_temp(113) <= A(113) xor novo_B(113) xor carry_temp(112);
			soma_temp(114) <= A(114) xor novo_B(114) xor carry_temp(113);
			soma_temp(115) <= A(115) xor novo_B(115) xor carry_temp(114);
			soma_temp(116) <= A(116) xor novo_B(116) xor carry_temp(115);
			soma_temp(117) <= A(117) xor novo_B(117) xor carry_temp(116);
			soma_temp(118) <= A(118) xor novo_B(118) xor carry_temp(117);
			soma_temp(119) <= A(119) xor novo_B(119) xor carry_temp(118);
			soma_temp(120) <= A(120) xor novo_B(120) xor carry_temp(119);
			soma_temp(121) <= A(121) xor novo_B(121) xor carry_temp(120);
			soma_temp(122) <= A(122) xor novo_B(122) xor carry_temp(121);
			soma_temp(123) <= A(123) xor novo_B(123) xor carry_temp(122);
			soma_temp(124) <= A(124) xor novo_B(124) xor carry_temp(123);
			soma_temp(125) <= A(125) xor novo_B(125) xor carry_temp(124);
			soma_temp(126) <= A(126) xor novo_B(126) xor carry_temp(125);
			soma_temp(127) <= A(127) xor novo_B(127) xor carry_temp(126);
			

      

			carry_temp(0) <=    (seletor(1) and (A(0) or novo_B(0))) or (A(0) and novo_B(0));
	    	carry_temp(1) <= (carry_temp(0) and (A(1) or novo_B(1))) or (A(1) and novo_B(1));
			carry_temp(2) <= (carry_temp(1) and (A(2) or novo_B(2))) or (A(2) and novo_B(2));
			carry_temp(3) <= (carry_temp(2) and (A(3) or novo_B(3))) or (A(3) and novo_B(3));
			carry_temp(4) <= (carry_temp(3) and (A(4) or novo_B(4))) or (A(4) and novo_B(4));
			carry_temp(5) <= (carry_temp(4) and (A(5) or novo_B(5))) or (A(5) and novo_B(5));
			carry_temp(6) <= (carry_temp(5) and (A(6) or novo_B(6))) or (A(6) and novo_B(6));
			carry_temp(7) <= (carry_temp(6) and (A(7) or novo_B(7))) or (A(7) and novo_B(7));
			carry_temp(8) <= (carry_temp(7) and (A(8) or novo_B(8))) or (A(8) and novo_B(8));
		    carry_temp(9) <= (carry_temp(8) and (A(9) or novo_B(9))) or (A(9) and novo_B(9));
			carry_temp(10) <= (carry_temp(9) and (A(10) or novo_B(10))) or (A(10) and novo_B(10));
			carry_temp(11) <= (carry_temp(10) and (A(11) or novo_B(11))) or (A(11) and novo_B(11));
			carry_temp(12) <= (carry_temp(11) and (A(12) or novo_B(12))) or (A(12) and novo_B(12));
			carry_temp(13) <= (carry_temp(12) and (A(13) or novo_B(13))) or (A(13) and novo_B(13));
			carry_temp(14) <= (carry_temp(13) and (A(14) or novo_B(14))) or (A(14) and novo_B(14));
			carry_temp(15) <= (carry_temp(14) and (A(15) or novo_B(15))) or (A(15) and novo_B(15));
			carry_temp(16) <= (carry_temp(15) and (A(16) or novo_B(16))) or (A(16) and novo_B(16));
		    carry_temp(17) <= (carry_temp(16) and (A(17) or novo_B(17))) or (A(17) and novo_B(17));
			carry_temp(18) <= (carry_temp(17) and (A(18) or novo_B(18))) or (A(18) and novo_B(18));
			carry_temp(19) <= (carry_temp(18) and (A(19) or novo_B(19))) or (A(19) and novo_B(19));
			carry_temp(20) <= (carry_temp(19) and (A(20) or novo_B(20))) or (A(20) and novo_B(20));
			carry_temp(21) <= (carry_temp(20) and (A(21) or novo_B(21))) or (A(21) and novo_B(21));
			carry_temp(22) <= (carry_temp(21) and (A(22) or novo_B(22))) or (A(22) and novo_B(22));
			carry_temp(23) <= (carry_temp(22) and (A(23) or novo_B(23))) or (A(23) and novo_B(23));
			carry_temp(24) <= (carry_temp(23) and (A(24) or novo_B(24))) or (A(24) and novo_B(24));
		    carry_temp(25) <= (carry_temp(24) and (A(25) or novo_B(25))) or (A(25) and novo_B(25));
			carry_temp(26) <= (carry_temp(25) and (A(26) or novo_B(26))) or (A(26) and novo_B(26));
			carry_temp(27) <= (carry_temp(26) and (A(27) or novo_B(27))) or (A(27) and novo_B(27));
			carry_temp(28) <= (carry_temp(27) and (A(28) or novo_B(28))) or (A(28) and novo_B(28));
			carry_temp(29) <= (carry_temp(28) and (A(29) or novo_B(29))) or (A(29) and novo_B(29));
			carry_temp(30) <= (carry_temp(29) and (A(30) or novo_B(30))) or (A(30) and novo_B(30));
			carry_temp(31) <= (carry_temp(30) and (A(31) or novo_B(31))) or (A(31) and novo_B(31));
			carry_temp(32) <= (carry_temp(31) and (A(32) or novo_B(32))) or (A(32) and novo_B(32));
			carry_temp(33) <= (carry_temp(32) and (A(33) or novo_B(33))) or (A(33) and novo_B(33));
			carry_temp(34) <= (carry_temp(33) and (A(34) or novo_B(34))) or (A(34) and novo_B(34));
			carry_temp(35) <= (carry_temp(34) and (A(35) or novo_B(35))) or (A(35) and novo_B(35));
			carry_temp(36) <= (carry_temp(35) and (A(36) or novo_B(36))) or (A(36) and novo_B(36));
			carry_temp(37) <= (carry_temp(36) and (A(37) or novo_B(37))) or (A(37) and novo_B(37));
			carry_temp(38) <= (carry_temp(37) and (A(38) or novo_B(38))) or (A(38) and novo_B(38));
			carry_temp(39) <= (carry_temp(38) and (A(39) or novo_B(39))) or (A(39) and novo_B(39));
			carry_temp(40) <= (carry_temp(39) and (A(40) or novo_B(40))) or (A(40) and novo_B(40));
			carry_temp(41) <= (carry_temp(40) and (A(41) or novo_B(41))) or (A(41) and novo_B(41));
			carry_temp(42) <= (carry_temp(41) and (A(42) or novo_B(42))) or (A(42) and novo_B(42));
			carry_temp(43) <= (carry_temp(42) and (A(43) or novo_B(43))) or (A(43) and novo_B(43));
			carry_temp(44) <= (carry_temp(43) and (A(44) or novo_B(44))) or (A(44) and novo_B(44));
			carry_temp(45) <= (carry_temp(44) and (A(45) or novo_B(45))) or (A(45) and novo_B(45));
			carry_temp(46) <= (carry_temp(45) and (A(46) or novo_B(46))) or (A(46) and novo_B(46));
			carry_temp(47) <= (carry_temp(46) and (A(47) or novo_B(47))) or (A(47) and novo_B(47));
			carry_temp(48) <= (carry_temp(47) and (A(48) or novo_B(48))) or (A(48) and novo_B(48));
			carry_temp(49) <= (carry_temp(48) and (A(49) or novo_B(49))) or (A(49) and novo_B(49));
			carry_temp(50) <= (carry_temp(49) and (A(50) or novo_B(50))) or (A(50) and novo_B(50));
			carry_temp(51) <= (carry_temp(50) and (A(51) or novo_B(51))) or (A(51) and novo_B(51));
			carry_temp(52) <= (carry_temp(51) and (A(52) or novo_B(52))) or (A(52) and novo_B(52));
			carry_temp(53) <= (carry_temp(52) and (A(53) or novo_B(53))) or (A(53) and novo_B(53));
			carry_temp(54) <= (carry_temp(53) and (A(54) or novo_B(54))) or (A(54) and novo_B(54));
			carry_temp(55) <= (carry_temp(54) and (A(55) or novo_B(55))) or (A(55) and novo_B(55));
			carry_temp(56) <= (carry_temp(55) and (A(56) or novo_B(56))) or (A(56) and novo_B(56));
			carry_temp(57) <= (carry_temp(56) and (A(57) or novo_B(57))) or (A(57) and novo_B(57));
			carry_temp(58) <= (carry_temp(57) and (A(58) or novo_B(58))) or (A(58) and novo_B(58));
			carry_temp(59) <= (carry_temp(58) and (A(59) or novo_B(59))) or (A(59) and novo_B(59));
			carry_temp(60) <= (carry_temp(59) and (A(60) or novo_B(60))) or (A(60) and novo_B(60));
			carry_temp(61) <= (carry_temp(60) and (A(61) or novo_B(61))) or (A(61) and novo_B(61));
			carry_temp(62) <= (carry_temp(61) and (A(62) or novo_B(62))) or (A(62) and novo_B(62));
			carry_temp(63) <= (carry_temp(62) and (A(63) or novo_B(63))) or (A(63) and novo_B(63));
			carry_temp(64) <= (carry_temp(63) and (A(64) or novo_B(64))) or (A(64) and novo_B(64));
			carry_temp(65) <= (carry_temp(64) and (A(65) or novo_B(65))) or (A(65) and novo_B(65));
			carry_temp(66) <= (carry_temp(65) and (A(66) or novo_B(66))) or (A(66) and novo_B(66));
		    carry_temp(67) <= (carry_temp(66) and (A(67) or novo_B(67))) or (A(67) and novo_B(67));
			carry_temp(68) <= (carry_temp(67) and (A(68) or novo_B(68))) or (A(68) and novo_B(68));
			carry_temp(69) <= (carry_temp(68) and (A(69) or novo_B(69))) or (A(69) and novo_B(69));
			carry_temp(70) <= (carry_temp(69) and (A(70) or novo_B(70))) or (A(70) and novo_B(70));
			carry_temp(71) <= (carry_temp(70) and (A(71) or novo_B(71))) or (A(71) and novo_B(71));
			carry_temp(72) <= (carry_temp(71) and (A(72) or novo_B(72))) or (A(72) and novo_B(72));
			carry_temp(73) <= (carry_temp(72) and (A(73) or novo_B(73))) or (A(73) and novo_B(73));
			carry_temp(74) <= (carry_temp(73) and (A(74) or novo_B(74))) or (A(74) and novo_B(74));
		    carry_temp(75) <= (carry_temp(74) and (A(75) or novo_B(75))) or (A(75) and novo_B(75));
			carry_temp(76) <= (carry_temp(75) and (A(76) or novo_B(76))) or (A(76) and novo_B(76));
			carry_temp(77) <= (carry_temp(76) and (A(77) or novo_B(77))) or (A(77) and novo_B(77));
			carry_temp(78) <= (carry_temp(77) and (A(78) or novo_B(78))) or (A(78) and novo_B(78));
			carry_temp(79) <= (carry_temp(78) and (A(79) or novo_B(79))) or (A(79) and novo_B(79));
			carry_temp(80) <= (carry_temp(79) and (A(80) or novo_B(80))) or (A(80) and novo_B(80));
			carry_temp(81) <= (carry_temp(80) and (A(81) or novo_B(81))) or (A(81) and novo_B(81));
			carry_temp(82) <= (carry_temp(81) and (A(82) or novo_B(82))) or (A(82) and novo_B(82));
			carry_temp(83) <= (carry_temp(82) and (A(83) or novo_B(83))) or (A(83) and novo_B(83));
			carry_temp(84) <= (carry_temp(83) and (A(84) or novo_B(84))) or (A(84) and novo_B(84));
			carry_temp(85) <= (carry_temp(84) and (A(85) or novo_B(85))) or (A(85) and novo_B(85));
			carry_temp(86) <= (carry_temp(85) and (A(86) or novo_B(86))) or (A(86) and novo_B(86));
			carry_temp(87) <= (carry_temp(86) and (A(87) or novo_B(87))) or (A(87) and novo_B(87));
			carry_temp(88) <= (carry_temp(87) and (A(88) or novo_B(88))) or (A(88) and novo_B(88));
			carry_temp(89) <= (carry_temp(88) and (A(89) or novo_B(89))) or (A(89) and novo_B(89));
			carry_temp(90) <= (carry_temp(89) and (A(90) or novo_B(90))) or (A(90) and novo_B(90));
			carry_temp(91) <= (carry_temp(90) and (A(91) or novo_B(91))) or (A(91) and novo_B(91));
			carry_temp(92) <= (carry_temp(91) and (A(92) or novo_B(92))) or (A(92) and novo_B(92));
			carry_temp(93) <= (carry_temp(92) and (A(93) or novo_B(93))) or (A(93) and novo_B(93));
			carry_temp(94) <= (carry_temp(93) and (A(94) or novo_B(94))) or (A(94) and novo_B(94));
			carry_temp(95) <= (carry_temp(94) and (A(95) or novo_B(95))) or (A(95) and novo_B(95));
			carry_temp(96) <= (carry_temp(95) and (A(96) or novo_B(46))) or (A(96) and novo_B(96));
			carry_temp(97) <= (carry_temp(96) and (A(97) or novo_B(97))) or (A(97) and novo_B(97));
			carry_temp(98) <= (carry_temp(97) and (A(98) or novo_B(98))) or (A(98) and novo_B(98));
			carry_temp(99) <= (carry_temp(98) and (A(99) or novo_B(99))) or (A(99) and novo_B(99));
			carry_temp(100) <= (carry_temp(99) and (A(100) or novo_B(100))) or (A(100) and novo_B(100));
			carry_temp(101) <= (carry_temp(100) and (A(101) or novo_B(101))) or (A(101) and novo_B(101));
			carry_temp(102) <= (carry_temp(101) and (A(102) or novo_B(102))) or (A(102) and novo_B(102));
			carry_temp(103) <= (carry_temp(102) and (A(103) or novo_B(103))) or (A(103) and novo_B(103));
			carry_temp(104) <= (carry_temp(103) and (A(104) or novo_B(104))) or (A(104) and novo_B(104));
			carry_temp(105) <= (carry_temp(104) and (A(105) or novo_B(105))) or (A(105) and novo_B(105));
			carry_temp(106) <= (carry_temp(105) and (A(106) or novo_B(106))) or (A(106) and novo_B(106));
			carry_temp(107) <= (carry_temp(106) and (A(107) or novo_B(107))) or (A(107) and novo_B(107));
			carry_temp(108) <= (carry_temp(107) and (A(108) or novo_B(108))) or (A(108) and novo_B(108));
			carry_temp(109) <= (carry_temp(108) and (A(109) or novo_B(109))) or (A(109) and novo_B(109));
			carry_temp(110) <= (carry_temp(109) and (A(110) or novo_B(110))) or (A(110) and novo_B(110));
			carry_temp(111) <= (carry_temp(110) and (A(111) or novo_B(111))) or (A(111) and novo_B(111));
			carry_temp(112) <= (carry_temp(111) and (A(112) or novo_B(112))) or (A(112) and novo_B(112));
			carry_temp(113) <= (carry_temp(112) and (A(113) or novo_B(113))) or (A(113) and novo_B(113));
			carry_temp(114) <= (carry_temp(113) and (A(114) or novo_B(114))) or (A(114) and novo_B(114));
			carry_temp(115) <= (carry_temp(114) and (A(115) or novo_B(115))) or (A(115) and novo_B(115));
			carry_temp(116) <= (carry_temp(115) and (A(116) or novo_B(116))) or (A(116) and novo_B(116));
			carry_temp(117) <= (carry_temp(116) and (A(117) or novo_B(117))) or (A(117) and novo_B(117));
			carry_temp(118) <= (carry_temp(117) and (A(118) or novo_B(118))) or (A(118) and novo_B(118));
			carry_temp(119) <= (carry_temp(118) and (A(119) or novo_B(119))) or (A(119) and novo_B(119));
			carry_temp(120) <= (carry_temp(119) and (A(120) or novo_B(120))) or (A(120) and novo_B(120));
			carry_temp(121) <= (carry_temp(120) and (A(121) or novo_B(121))) or (A(121) and novo_B(121));
			carry_temp(122) <= (carry_temp(121) and (A(122) or novo_B(122))) or (A(122) and novo_B(122));
			carry_temp(123) <= (carry_temp(122) and (A(123) or novo_B(123))) or (A(123) and novo_B(123));
			carry_temp(124) <= (carry_temp(123) and (A(124) or novo_B(124))) or (A(124) and novo_B(124));
			carry_temp(125) <= (carry_temp(124) and (A(125) or novo_B(125))) or (A(125) and novo_B(125));
			carry_temp(126) <= (carry_temp(125) and (A(126) or novo_B(126))) or (A(126) and novo_B(126));
			carry_temp(127) <= (carry_temp(126) and (A(127) or novo_B(127))) or (A(127) and novo_B(127));



			overflow_temp <= carry_temp(127) xor carry_temp(126);
		
		   Overflow <= overflow_temp;

--------------------------------------------------------------------------------
--		Regiao que calcula a compara��o										  --	
--------------------------------------------------------------------------------

-- No codigo da comparacao (110) sera executada a subtracao na parte relativa

-- ao calculo da SOMA, SUBTRACAO e INCREMENTO.

		
		igual_temp <= not(overflow_temp)  when soma_temp = "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" 
					else '0'; -- Quando subtracao e zero
  		
  		Igual <= igual_temp; 

-- Se nao teve overflow -> resultado baseado no bit mais significativo de A - B.
-- Se teve overflow -> A e B possuem, necessariamente, sinais contrarios. Resultado 
-- baseado no bit mais significativo de A.
-- Devemos tambem checar se A e B nao sao iguais
		Maior <= ( (not(soma_temp(127)) and (not(overflow_temp)) )or (overflow_temp and (not(A(127))))) and (not(igual_temp));

-- Se nao teve overflow -> resultado baseado no bit mais significativo de A - B.
-- Se teve overflow -> A e B possuem, necessariamente, sinais contrarios. Resultado 
-- baseado no bit mais significativo de A.
		Menor <= ((soma_temp(127) and (not(overflow_temp))) or (overflow_temp and A(127)));


end behavioral;
