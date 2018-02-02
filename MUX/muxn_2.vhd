-- Fichier : muxn_2.vhd
-- Auteur : GARCIA Guillaume & SOCHALA Antoine

-- MULTIPLEXEUR � 2 entr�es de N bits

library ieee;				-- importe le biblioth�que "ieee"

use ieee.std_logic_1164.all;-- rend visible "tous" les �l�ments
							-- du paquetage "std_logic_1164"
							-- de la biblioth�que "ieee"
							-- dont le type Std_Logic qui mod�lise qualitativement
							-- la valeur d'une borne �lectrique (0, 1, Z, - ...) ;
							-- type Bit={0, 1} , type Boolean = {FALSE, TRUE}.

-- ENTITY = SPECIFICATION DE L'INTERFACE (DECLARATION) DE L'OPERATEUR

entity MUXN_2 is				-- nom de l'op�rateur = MUXN_2
	generic (N : Integer := 4);	-- param�tre N bits
	port(						-- liste de d�clarations des signaux de l'interface
		s: 	in		Std_Logic;	-- entr�e s � 1 bit : commande de s�lection
		x0: in  	Std_Logic_Vector(N-1 downto 0);	-- entr�e x0 � N bit : donn�e n�0
		x1: in		Std_Logic_Vector(N-1 downto 0);	-- entr�e x1 � N bit : donn�e n�1
		y:	buffer	Std_Logic_Vector(N-1 downto 0));-- sortie rebouclable y � N  bit : donn�e multiplex�e
end entity;

-- ARCHITECTURE = SPECIFICATION DU COMPORTEMENT (DEFINITION) DE L'OPERATION

architecture MUXN_2_arch of MUXN_2 is	-- lie l'architecture � l'entit� MUX1_2
	constant TPD_PASS: Time := 11.5 ns;
	constant TPD_IO: Time := 4 ns;
begin

y <= x1 when s ='1' else x0 after TPD_PASS + TPD_IO;	-- branche y sur x0 * /s + x1 * s
							-- (conditionnelle concurrente)
end architecture;
