-- Fichier : alsun.vhd
-- Auteurs : GARCIA Guillaume & JAMET Alexandre

-- Unité de calcul arithmétique, logique et décalage.

library ieee;
use ieee.std_logic_1164.all;

entity ALSUN is
	generic (N : Integer := 4);								
	port(										
		P: in	Std_Logic_Vector(4 downto 0);		-- oPeration (sur 5 bits)
		I: in	Std_Logic;							-- Inpute carry
		ADR: in	Std_Logic;							-- Localisation du demi-mot à partir de la gauche
		A: in  Std_Logic_Vector(N-1 downto 0);		-- Opérande A
		B: in  Std_Logic_Vector(N-1 downto 0);		-- Opérande B
		R:	buffer	Std_Logic_Vector(N-1 downto 0);	-- Result
		C:	buffer	Std_Logic;						-- Corry output
		V:	buffer	Std_Logic);						-- oVerflow
end entity;


architecture ALSUN_arch of ALSUN is

-- Code P des opérations:

-- GROUPE I :
	constant ALSU_ADD : Std_Logic_Vector(4 downto 0) := "00110";	-- ADD
	constant ALSU_ADC : Std_Logic_Vector(4 downto 0) := "00000";	-- ADC
	constant ALSU_SUB : Std_Logic_Vector(4 downto 0) := "00111";	-- SUB
	constant ALSU_AND : Std_Logic_Vector(4 downto 0) := "00100";	-- AND
	constant ALSU_IOR : Std_Logic_Vector(4 downto 0) := "00101";	-- IOR (ou OR)
	constant ALSU_XOR : Std_Logic_Vector(4 downto 0) := "00001";	-- XOR

-- GROUPE II :
	constant ALSU_NOT : Std_Logic_Vector(4 downto 0) := "10100";	-- NOT
	constant ALSU_NEG : Std_Logic_Vector(4 downto 0) := "10111";	-- NEG
	constant ALSU_SRL : Std_Logic_Vector(4 downto 0) := "10010";	-- SRL
	constant ALSU_SRA : Std_Logic_Vector(4 downto 0) := "10011";	-- SRA
	constant ALSU_RRC : Std_Logic_Vector(4 downto 0) := "10001";	-- RRC
	constant ALSU_SWP : Std_Logic_Vector(4 downto 0) := "11010";	-- SWP

-- GROUPE III :
	constant ALSU_PSB : Std_Logic_Vector(4 downto 0) := "01000";	-- SWP

-- Signaux internes :
	signal RI: Std_Logic_Vector(N - 1 downto 0); -- Retenues entees
	signal RC: Std_Logic_Vector(N - 1 downto 0); -- Retenues sorties

	attribute SYNTHESIS_OFF of RI: signal is TRUE;

begin


-- Bloc calculateur de retenue

RI(0) <= '0' when P = ALSU_ADD else
		 I when P = ALSU_ADC else
		 '1' when P = ALSU_SUB else
		 '1' when P = ALSU_NEG else
		 '-'; -- Autres ops

RC <= (A and B) or (RI and B) or (RI and A) when P = ALSU_ADD else 
	  (A and not B) or (RI and  not B) or (RI and A) when P = ALSU_SUB else -- B est neg
	  RI and not B when P = ALSU_NEG else  -- A = 0 et B est neg
	  (others => '-'); -- Autres ops
	  
carry_gen: for j in 1 to N - 1 generate
	RI(j) <= RC(j - 1);
end generate carry_gen;


-- Bloc process combinatoire

alsu_process: process(P, RI, RC, A, B, ADR, I) -- L'ALSU est combinatoire donc chaque signaux d'entrées directement utilisés changent la sortie
	
	variable RV: Std_Logic_Vector(N-1 downto 0); -- Résultat du process

	begin
		case P is
		    -- Groupe I
			when ALSU_ADD =>
				RV := A xor B xor RI;
				V <= RI(N-1) xor RI(N-2);
				C <= RI(N-1);
			when ALSU_ADC =>
				RV := A xor B xor RI;
				V <= RI(N-1) xor RI(N-2);
				C <= RI(N-1);
			when ALSU_XOR =>
				RV := A xor B;
				V <= '0';
				C <= '0';
			when ALSU_SUB => 
				RV := A xor not B xor RI;
				V <= RI(N-1) xor RI(N-2);
				C <= not RI(N-1);
			when ALSU_IOR =>
				RV := A or B;
				V <= '0';
				C <= '0';
		   	when ALSU_AND =>
				RV := A and B;
				V <= '0';
				C <= '0';

			-- Groupe II
		    when ALSU_NOT =>
				RV := not B;
				V <= '0';
				C <= '0';
			when ALSU_NEG =>
				RV := not B xor RI;
				V <= RI(N-1) xor RI(N-2);
				C <= not RI(N-1);
			when ALSU_SWP =>
				for k in 0 to N/2-1 loop
					RV(k) := B(k+N/2); -- Demi mot droit de R
					RV(k+N/2) := B(k); -- Demi mot gauche de R
				end loop;
				C <= '0';
				V <= '0';
			when ALSU_SRL =>
				RV(N-1) := '0'; -- Bit tout à gauche = 0
				for k in 0 to N-2 loop
					RV(k) := B(k+1); -- Bit à gauche => à droite
				end loop;
				C <= B(0);
				V <= '0';
			when ALSU_SRA =>
				RV(N-1) := B(N-1); -- Bit tout à gauche = Le bit de poids de B (recopié)
				for k in 0 to N-2 loop
					RV(k) := B(k+1); -- Bit à gauche => à droite
				end loop;
				C <= B(0);
				V <= '0';
			when ALSU_RRC =>
				RV(N-1) := I; -- Bit tout à gauche = I (input carry)
				for k in 0 to N-2 loop
					RV(k) := B(k+1); -- Bit à gauche => à droite
				end loop;
				C <= B(0);
				V <= '0';

			-- Groupe III
			when ALSU_PSB =>
				RV := B; -- Pass B
				C <= '0';
				V <= '0';
			when others =>
				RV := (others => '-'); -- Ce qui évite la mémorisation et simplifie la logique => pas de mémoire ! ALSU est combinatoire
				C <= '0';
				V <= '0';
		end case;

	R <= RV; -- Affectation finale

end process;

end architecture;
