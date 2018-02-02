-- Fichier : lffn.vhd
-- Auteur : GARCIA Guillaume & SOCHALA Antoine

-- Bascule D "Data Flip Flop" � N bits

library ieee;
use ieee.std_logic_1164.all;

-- ENTITY = SPECIFICATION DE L'INTERFACE (DECLARATION) DE L'OPERATEUR
entity DFFN is	
	generic (N : Integer := 4);							-- param�tre N bits
	port(												-- liste de d�clarations des signaux de l'interface
		clock: in		Std_Logic;					    -- horloge
		D: in  		Std_Logic_Vector(N-1 downto 0);		-- entr�e D � N bit
		Q: buffer	Std_Logic_Vector(N-1 downto 0));	-- sortie Q � N bit
end entity;


-- ARCHITECTURE = SPECIFICATION DU COMPORTEMENT (DEFINITION) DE L'OPERATION
architecture DFFN_arch of DFFN is
begin

and_proc: process(clock, D)
	begin
	if (clock'event and clock='1') then
		Q <= D;
	end if;
end process;

end architecture;

-- Question b: 
-- Voici les �quations :
--    q(0).D =
--          d(0) 
--
--    q(0).C =
--          clock 
--
--    q(1).D =
--          d(1) 
--
--    q(1).C =
--          clock 
--
--    q(2).D =
--          d(2) 
--
--    q(2).C =
--          clock 
--
--    q(3).D =
--          d(3) 
--
--    q(3).C =
--          clock 
--
-- Il s'agit d'une m�morisation de chaque bit de D (par la commande D : Data) 
-- dans Q par la commande C (synchronisation de la bascule)