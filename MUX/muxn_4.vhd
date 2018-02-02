-- Fichier : muxn_4.vhd
-- Auteur : GARCIA Guillaume & SOCHALA Antoine

-- MULTIPLEXEUR � 4 entr�es de N bits

library ieee;				-- importe le biblioth�que "ieee"

use ieee.std_logic_1164.all;-- rend visible "tous" les �l�ments
							-- du paquetage "std_logic_1164"
							-- de la biblioth�que "ieee"
							-- dont le type Std_Logic qui mod�lise qualitativement
							-- la valeur d'une borne �lectrique (0, 1, Z, - ...) ;
							-- type Bit={0, 1} , type Boolean = {FALSE, TRUE}.

-- ENTITY = SPECIFICATION DE L'INTERFACE (DECLARATION) DE L'OPERATEUR

entity MUXN_4 is				-- nom de l'op�rateur = MUXN_4
	generic (N : Integer := 4);	-- param�tre N bits
	port(						-- liste de d�clarations des signaux de l'interface
		s: 	in		Std_Logic_Vector(1 downto 0);	-- entr�e s � 2 bits : commande de s�lection
		x0: in  	Std_Logic_Vector(N-1 downto 0);	-- entr�e x0 � N bit : donn�e n�0
		x1: in		Std_Logic_Vector(N-1 downto 0);	-- entr�e x1 � N bit : donn�e n�1
		x2: in  	Std_Logic_Vector(N-1 downto 0);	-- entr�e x2 � N bit : donn�e n�2
		x3: in		Std_Logic_Vector(N-1 downto 0);	-- entr�e x3 � N bit : donn�e n�3
		y:	buffer	Std_Logic_Vector(N-1 downto 0));-- sortie rebouclable y � N  bit : donn�e multiplex�e
end entity;

-- ARCHITECTURE = SPECIFICATION DU COMPORTEMENT (DEFINITION) DE L'OPERATION

architecture MUXN_4_arch of MUXN_4 is	-- lie l'architecture � l'entit� MUXN_4
	constant TPD_PASS: Time := 11.5 ns; -- ou TPD = 15 ns c'est une simplification 
	constant TPD_IO: Time := 4 ns;
begin

with s select
	y <= x0	 after TPD_PASS + TPD_IO	when "00",
		 x1 after TPD_PASS + TPD_IO 	when "01",
		 x2 after TPD_PASS + TPD_IO		when "10",
		 x3 after TPD_PASS + TPD_IO		when "11",
		 (others => '-') after TPD_PASS + TPD_IO	when others;
end architecture;