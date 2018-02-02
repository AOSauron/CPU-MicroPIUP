-- Fichier : bufn.vhd
-- Auteur : GARCIA Guillaume & SOCHALA Antoine

-- Tampon "tri-state buffer" à N bits

library ieee;
use ieee.std_logic_1164.all;

-- ENTITY = SPECIFICATION DE L'INTERFACE (DECLARATION) DE L'OPERATEUR
entity BUFN is	
	generic (N : Integer := 4);							-- paramètre N bits
	port(												-- liste de déclarations des signaux de l'interface
		E: in		Std_Logic;					    	-- Commande de validation du tampon
		I: in  		Std_Logic_Vector(N-1 downto 0);		-- entrée I à N bits
		O: buffer	Std_Logic_Vector(N-1 downto 0));	-- sortie O à N bits
end entity;


-- ARCHITECTURE = SPECIFICATION DU COMPORTEMENT (DEFINITION) DE L'OPERATION
architecture BUFN_arch of BUFN is
begin

and_proc: process(E, I)
	begin
	if (E = '1') then
		O <= I;
	else
		O <= (others => 'Z');
	end if;
end process;

end architecture;

-- Question b: 
-- Voici les équations :
--    o(0) =
--          i(0) 
--
--    o(0).OE =
--          e 
--
--    o(1) =
--          i(1) 
--
--    o(1).OE =
--          e 
--
--    o(2) =
--          i(2) 
--
--    o(2).OE =
--         e 
--
--    o(3) =
--          i(3) 
--
--    o(3).OE =
--         e 
--
-- Il s'agit d'une mémorisation de chaque bit de I dans O 
-- par la commande OE (commande de validation E du tampon) et le signal E
