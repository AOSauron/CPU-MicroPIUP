-- Fichier : tprf1.vhd
-- Auteurs : GARCIA Guillaume & SOCHALA Antoine

-- BLOC triple port de 4 registres 

library ieee;
use ieee.std_logic_1164.all;
use work.basic_pack.all;

entity TPRF1 is
	generic (alpha : Integer := 2;						-- Largeur des sélecteurs (bits)
			 M : Integer := 4;							-- Nombre de registres
			 N : Integer := 4);							-- Largeurs des registres (bits)
	port(
		clock:	in Std_Logic;							-- Horloge
		R:	in Std_Logic;								-- Reset
		L:	in Std_Logic;								-- Load
		INS:in Std_Logic_Vector(alpha - 1 downto 0);			-- Input selector
		OAS:in Std_Logic_Vector(alpha - 1 downto 0);	-- Output selector A
		OBS:in Std_Logic_Vector(alpha - 1 downto 0);	-- Output selector B
		I:	in Std_Logic_Vector(N - 1 downto 0);		-- Entrée de données
		OA:	buffer Std_Logic_Vector(N - 1 downto 0);	-- Sortie A de données
		OB:	buffer Std_Logic_Vector(N - 1 downto 0));	-- RSortie B de données
end entity;

architecture TPRF1_arch of TPRF1 is
	signal R0: Std_Logic_Vector(N - 1 downto 0); -- Valeur du registre R0
	signal R1: Std_Logic_Vector(N - 1 downto 0); -- Valeur du registre R1
	signal R2: Std_Logic_Vector(N - 1 downto 0); -- Valeur du registre R2
	signal R3: Std_Logic_Vector(N - 1 downto 0); -- Valeur du registre R3

	signal L0: Std_Logic; -- Entrée L0 du mux
	signal L1: Std_Logic; -- Entrée L1 du mux
	signal L2: Std_Logic; -- Entrée L2 du mux
	signal L3: Std_Logic; -- Entrée L3 du mux


begin

-- Démultipléxeur :
de_mux: process(L, INS)
begin
if (INS = "00") then
	L0 <= L;
	L1 <= '0';
	L2 <= '0';
   	L3 <= '0';
elsif (INS = "01") then
	L0 <= '0';
	L1 <= L;
	L2 <= '0';
   	L3 <= '0';
elsif (INS = "10") then
	L0 <= '0';
	L1 <= '0';
	L2 <= L;
   	L3 <= '0';
else 
	L0 <= '0';
	L1 <= '0';
	L2 <= '0';
   	L3 <= L;
end if;
end process;

reg0 : REGN generic map (N => N)
			port map (
			R => R,
			L => L0,
			clock => clock,
			D => I,
			Q => R0);

reg1 : REGN generic map (N => N)
			port map (
			R => R,
			L => L1,
			clock => clock,
			D => I,
			Q => R1);

reg2 : REGN generic map (N => N)
			port map (
			R => R,
			L => L2,
			clock => clock,
			D => I,
			Q => R2);

reg3 : REGN	generic map (N => N)
			port map (
			R => R,
			L => L3,
			clock => clock,
			D => I,
			Q => R3);

muxa : MUXN_4 generic map (N => N)
			  port map (
			  	s => OAS,
				x0 => R0,
				x1 => R1,
				x2 => R2,
				x3 => R3,
				y => OA);

muxb : MUXN_4 generic map (N => N)
			  port map (
			    s => OBS,
				x0 => R0,
				x1 => R1,
				x2 => R2,
				x3 => R3,
				y => OB);

end architecture;


-- Question 2)
-- a)
-- Exemple avec le polynome booléen OA(0):
-- 
--    oa(0) =
--          oas(0) * oas(1) * r3_0.Q 
--        + /oas(0) * oas(1) * r2_0.Q 
--        + oas(0) * /oas(1) * r1_0.Q 
--        + /oas(0) * /oas(1) * r0_0.Q 
--
-- Il y a donc 4 monomes dans chacun de ses polynomes
--
-- b)
-- /!\  A FAAAAAAIIIIRE
--
-- c)
-- N=2 => 12 cells used
-- N=4 => 24 cells used
-- N=8 => 48 cells used
--
-- On en déduit que nombre de cellules utilisées = 6 * N où N est le nombre de bits.
--
-- d)
-- On conjecture qu'une cellule est utilisée par bit et par composant : or il y a M registres + 2 multiplexeurs. Le tout sur N bits.
-- La formule générale serait donc : Nombre de cellules utilisés = (M+2)*N
