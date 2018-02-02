-- Fichier : regn.vhd
-- Auteur : GARCIA Guillaume & SOCHALA Antoine

-- REGISTRE � N bits

library ieee;
use ieee.std_logic_1164.all;

-- ENTITY = SPECIFICATION DE L'INTERFACE (DECLARATION) DE L'OPERATEUR

entity REGN is										-- nom de l'op�rateur = REGN
	generic (N : Integer := 4);						-- param�tre N bits
	port(											-- liste de d�clarations des signaux de l'interface
		R: in	Std_Logic;							-- Commande d'effacement
		L: in	Std_Logic;							-- Commande de chargement
		clock: in	Std_Logic;						-- Horloge
		D: 	in  	Std_Logic_Vector(N-1 downto 0);	-- entr�e D � N bits
		Q:	buffer	Std_Logic_Vector(N-1 downto 0));-- sortie Q � N bits 
end entity;

-- ARCHITECTURE = SPECIFICATION DU COMPORTEMENT (DEFINITION) DE L'OPERATION

architecture REGN_arch of REGN is	-- lie l'architecture � l'entit� REGN

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
--	On utilise bien la commande clock pour la synchronisation et l'effacement s�quentielle
-- 	est bien repr�sent� dans les �quations (il en va de m�me pour le chargement).
