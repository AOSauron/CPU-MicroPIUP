--- Compteur binaire synchrone de N bits
---
--- Fichier: cntn.vhd
---
--- Binome: GARCIA Guillaume et SOCHALA Antoine

library ieee;
use ieee.std_logic_1164.all;

entity CNTN is
	generic (N : Integer := 16);						-- Nombre de bits
	port(
		clock:	in Std_Logic;						-- Horloge
		R:	in Std_Logic;							-- Reset
		L:	in Std_Logic;							-- Load
		T:	in Std_Logic;							-- Toggle (incrémentation)
		V:	in Std_Logic_Vector(N - 1 downto 0);	-- Valeur initiale
		D:	in Std_Logic_Vector(N - 1 downto 0);	-- Data
		Q:	buffer Std_Logic_Vector(N - 1 downto 0);-- Valeur de comptage
		C:	buffer Std_Logic);						-- Retenue sortante à gauche
end entity;

architecture CNTN_arch of CNTN is
	signal RI: Std_Logic_Vector(N - 1 downto 0); -- Retenues entees
	signal RC: Std_Logic_Vector(N - 1 downto 0); -- Retenues sorties
	signal S: Std_Logic_Vector(N - 1 downto 0); -- Signal interne S = Q#RI

	--attribute SYNTHESIS_OFF of RI: signal is TRUE;
	--attribute SYNTHESIS_OFF of RC: signal is TRUE;


begin
	-- Hemi-additionneur :
	RI(0) <= T;
	S <= Q xor RI;

	carry_gen: for j in 1 to N - 1 generate
		RI(j) <= RC(j - 1);
	end generate carry_gen;

	RC <= Q and RI;
	C <= RC(N - 1);
	-- Fin de l'hemi-additionneur

-- Comportement du compteur :
cnt_process: process(clock)
begin
	if (clock'event and clock='1') then
		if (R='1') then 				-- Init : Prio 0 (max)
			Q <= V;						
		elsif (L='1') then	-- Chargement : Prio 1
			Q <= D;
		else				-- Incrémentation : Prio 2 (min)
			Q <= S;
		end if;
	end if;
end process;

end architecture;

-- Question 2.1
-- Voici les équations intéressantes (en fonction de R et RL) :
--
--    q(0).D =
--          /l * /q(0).Q * /r * ri_0.CMB 
--        + /l * q(0).Q * /r * /ri_0.CMB 
--        + d(0) * l * /r 
--        + r * v(0) 
--
--  avec ri_0 = t 
--
--  Valeurs de q:
--  R=1 		=> q(0).D = v(0)
--  R=0 and L=1 => q(0).D = d(0)
--	R=0 and L=0 => q(0).D = /q(0).Q * t  
--                        +  q(0).Q * /t
--						  = q(0) xor t
--						  (= q xor ri)
--
--
--    q(1).D =
--          /l * /q(1).Q * /r * ri_1.CMB 
--        + /l * q(1).Q * /r * /ri_1.CMB 
--        + d(1) * l * /r 
--        + r * v(1) 
--
--	avec ri_1 = q(0).Q * ri_0.CMB = q(0) * t
--
--  Valeurs de q:
--  R=1 		=> q(1).D = v(1)
--  R=0 and L=1 => q(1).D = d(1)
--	R=0 and L=0 => q(1).D = /q(1) * (q(0) * t) 
-- 						  + q(1) * /(q(0) * t)
--						  = q(1) xor (q(0) * t)
--
--
--    q(2).D =
--          /l * /q(2).Q * /r * ri_2.CMB 
--        + /l * q(2).Q * /r * /ri_2.CMB 
--        + d(2) * l * /r 
--        + r * v(2) 
--
--	avec ri_2 = q(1).Q * ri_1.CMB = q(1).Q * q(0).Q * t
--
--  Valeurs de q:
--  R=1 		=> q(2).D = v(2)
--  R=0 and L=1 => q(2).D = d(2)
--	R=0 and L=0 => q(2).D = /q(2).Q * (q(1).Q* q(0).Q * t)  
--                        +  q(2).Q * /(q(1).Q * q(0).Q * t)
--						  = q(2) xor (q(1) * q(0) * t)
--
--
--    q(3).D =
--          /l * /q(3).Q * /r * ri_3.CMB 
--        + /l * q(3).Q * /r * /ri_3.CMB 
--        + d(3) * l * /r 
--        + r * v(3) 
--
--  avec ri_3 = q(2).Q * ri_2.CMB = q(2) * q(1).Q * q(0).Q * t
--
--  Valeurs de q:
--  R=1 		=> q(3).D = v(3)
--  R=0 and L=1 => q(3).D = d(3)
--	R=0 and L=0 => q(3).D = /q(3).Q * (q(2) * q(1).Q * q(0).Q * t)  
--                        +  q(3).Q * /(q(2) * q(1).Q * q(0).Q * t)
--						  = q(0) xor (q(2) * q(1) * q(0) * t)
--
--
-- Question 2.2
--   Q. a)
--	   N = 4:
--		DFF avec Synthesis OFF sur RC: fMAX = 22 MHz
--		DFF sans Synthesis OFF sur RC: fMAX = 83 MHz
--		TFF avec Synthesis OFF sur RC: fMAX = 22 MHz
--		TFF sans Synthesis OFF sur RC: fMAX = 83 MHz
--	   N = 16:
--		DFF avec Synthesis OFF sur RC: fMAX = 5 MHz
--		DFF sans Synthesis OFF sur RC: fMAX = 43 MHz
--		TFF avec Synthesis OFF sur RC: fMAX = 5 MHz
--		TFF sans Synthesis OFF sur RC: fMAX = 83 MHz
--
--	Q. b)
--	  Le meilleur choix quelque soit le nombre de bits semble être la synthèse 
--    optimale (TFF) SANS synthesis OFF sur RC qui donne 83MHz dans les deux cas N= 4 ou 16.
--
-- Question 2.3
-- Calculons :
--
--    rc_0 = q(0) * t 
--
--    rc_1 = q(1) * q(0) * t
--           
--    rc_2 = q(2) * q(1) * q(0) * t 
--	
--    rc_3 =q(3) * q(2) * q(1) * q(0) * t 
--
-- par conjecture (récurrence) : rc_m = produit(q(m)) * t, pour k allant de 0 à k-1
--
-- Question 2.4
-- Ce n'est pas nécessaire, puisqu'il est possible de d'exclure les signaux de retenue de la synthèse (explique 2.2).
-- En effet les retenues (RC) sont calculées combinatoirement par portes ET, inutile donc de créer des cellules supplémentaires pour cela.
-- De plus, il vaut mieux ne pas utiliser de DFF : les TFF comprennent déjà un Xor (utilisés pour les RI).
-- Cela explique les faibles performances avec Synthesis_off et/ou avec DFF (pour 16 bits surtout), trop de cellules sont utilisées.
