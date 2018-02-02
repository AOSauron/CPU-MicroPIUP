-- Fichier : lffn.vhd
-- Auteur : GARCIA Guillaume & SOCHALA Antoine

-- VERROU "Latch Flip Flop" � N bits

library ieee;
use ieee.std_logic_1164.all;

-- ENTITY = SPECIFICATION DE L'INTERFACE (DECLARATION) DE L'OPERATEUR
entity LFFN is	
	generic (N : Integer := 4);							-- param�tre N bits
	port(												-- liste de d�clarations des signaux de l'interface
		G: in		Std_Logic;							-- entr�e � 1 bit commande de passage
		D: in  		Std_Logic_Vector(N-1 downto 0);		-- entr�e D � N bit
		Q: buffer	Std_Logic_Vector(N-1 downto 0));	-- sortie Q � N bit
end entity;


-- ARCHITECTURE = SPECIFICATION DU COMPORTEMENT (DEFINITION) DE L'OPERATION
architecture LFFN_arch of LFFN is
begin

and_proc: process(G, D)
	begin
	if (G='1') then
		Q <= D;
	end if;
end process;

end architecture;

-- Question b: 
-- Voici les �quations :
--    q(0).D =
--         d(0) 
--
--    q(0).LH =
--          g 
--
--    q(1).D =
--         d(1) 
--
--    q(1).LH =
--          g 
--
--    q(2).D =
--          d(2) 
--
--    q(2).LH =
--          g 
--
--    q(3).D =
--          d(3) 
--
--    q(3).LH =
--          g 
--
-- Il s'agit d'une m�morisation de chaque bit de D (par la commande D : Data) 
-- dans Q par la commande LH (m�morisation de la bascule)
--
-----------------------------------------
--
-- Question c:
-- Nouvelles �quations :
--    q(0) =
--          d(0) * g 
--        + /g * q(0).CMB 
--
--    q(1) =
--          d(1) * g 
--        + /g * q(1).CMB 
--
--    q(2) =
--          d(2) * g 
--        + /g * q(2).CMB 
--
--    q(3) =
--          d(3) * g 
--        + /g * q(3).CMB 
-- 
-- Utilisation de AND (*) bit � bit entre G et D, et /G et Q;
-- r�cup�ration de la sortie du OU (+) (signal CMB de la cible CY37k)
-- Aucun verrou tout pret n'est donc utilis� pour la synthese, mais plutot des portes OR, AND et NOT.
