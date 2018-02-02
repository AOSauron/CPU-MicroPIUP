-- Fichier : passn.vhd
-- Auteur : GARCIA Guillaume & SOCHALA Antoine

-- PASSEUR à N bits

library ieee;
use ieee.std_logic_1164.all;

-- ENTITY = SPECIFICATION DE L'INTERFACE (DECLARATION) DE L'OPERATEUR
entity PASSN is	
	generic (N : Integer := 4);							-- paramètre N bits
	port(												-- liste de déclarations des signaux de l'interface
		G: in		Std_Logic;							-- entrée à 1 bit commande de passage
		I: in  		Std_Logic_Vector(N-1 downto 0);		-- entrée I à N bit
		O: buffer	Std_Logic_Vector(N-1 downto 0));	-- sortie O à N bit
end entity;


-- ARCHITECTURE = SPECIFICATION DU COMPORTEMENT (DEFINITION) DE L'OPERATION
architecture PASSN_arch of PASSN is
begin

and_proc: process(G, I)
	begin
	if (G='1') then
		O <= I;
	else
		O <= (others => '0');
	end if;
end process;

end architecture;

-- Question b: 
-- Voici les équations :
--    o(0) =
--          g * i(0) 
--
--    o(1) =
--          g * i(1) 
--
--    o(2) =
--          g * i(2) 
--
--    o(3) =
--          g * i(3)
--
-- Il s'agit de quatre AND1 bit à bit de chaque bit de G et I 
-- (réalisant donc un AND4 des signaux G et I, qui sont sur 4 bits)
