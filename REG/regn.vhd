-- Fichier : regn.vhd
-- Auteur : GARCIA Guillaume & SOCHALA Antoine

-- REGISTRE à N bits

library ieee;
use ieee.std_logic_1164.all;

-- ENTITY = SPECIFICATION DE L'INTERFACE (DECLARATION) DE L'OPERATEUR

entity REGN is										-- nom de l'opérateur = REGN
	generic (N : Integer := 4);						-- paramètre N bits
	port(											-- liste de déclarations des signaux de l'interface
		R: in	Std_Logic;							-- Commande d'effacement
		L: in	Std_Logic;							-- Commande de chargement
		clock: in	Std_Logic;						-- Horloge
		D: 	in  	Std_Logic_Vector(N-1 downto 0);	-- entrée D à N bits
		Q:	buffer	Std_Logic_Vector(N-1 downto 0));-- sortie Q à N bits 
end entity;

-- ARCHITECTURE = SPECIFICATION DU COMPORTEMENT (DEFINITION) DE L'OPERATION

architecture REGN_arch of REGN is	-- lie l'architecture à l'entité REGN

begin

and_proc: process(D, clock, R, L)
	begin
	if (clock'event and clock = '1') then
		if (R='1') then
			Q <= (others => '0');
		elsif (L='1') then
			Q <= D;
		end if;	
   	end if;
end process;

end architecture;


-- Question b)
-- Voici les equations :
--q(0).D =
--          d(0) * l * /r 
--        + /l * q(0).Q * /r 
--
--    q(0).C =
--          clock 
--
--    q(1).D =
--          d(1) * l * /r 
--        + /l * q(1).Q * /r 
--
--    q(1).C =
--          clock 
--
--    q(2).D =
--          d(2) * l * /r 
--        + /l * q(2).Q * /r 
--
--    q(2).C =
--          clock 
--
--    q(3).D =
--          d(3) * l * /r 
--        + /l * q(3).Q * /r 
--
--    q(3).C =
--          clock 
--
--
--	On utilise bien la commande clock pour la synchronisation et l'effacement séquentielle
-- 	est bien représenté dans les équations (il en va de même pour le chargement).
