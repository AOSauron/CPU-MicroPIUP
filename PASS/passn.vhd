-- Fichier : passn.vhd
-- Auteur : GARCIA Guillaume & SOCHALA Antoine

-- PASSEUR � N bits

library ieee;
use ieee.std_logic_1164.all;

-- ENTITY = SPECIFICATION DE L'INTERFACE (DECLARATION) DE L'OPERATEUR
entity PASSN is	
	generic (N : Integer := 4);							-- param�tre N bits
	port(												-- liste de d�clarations des signaux de l'interface
		G: in		Std_Logic;							-- entr�e � 1 bit commande de passage
		I: in  		Std_Logic_Vector(N-1 downto 0);		-- entr�e I � N bit
		O: buffer	Std_Logic_Vector(N-1 downto 0));	-- sortie O � N bit
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
-- Voici les �quations :
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
-- Il s'agit de quatre AND1 bit � bit de chaque bit de G et I 
-- (r�alisant donc un AND4 des signaux G et I, qui sont sur 4 bits)
