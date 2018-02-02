-- Fichier : mux4_2.vhd
-- Auteur : GARCIA Guillaume & SOCHALA Antoine

-- MULTIPLEXEUR � 2 entr�es de 4 bits

library ieee;				-- importe le biblioth�que "ieee"

use ieee.std_logic_1164.all;-- rend visible "tous" les �l�ments
							-- du paquetage "std_logic_1164"
							-- de la biblioth�que "ieee"
							-- dont le type Std_Logic qui mod�lise qualitativement
							-- la valeur d'une borne �lectrique (0, 1, Z, - ...) ;
							-- type Bit={0, 1} , type Boolean = {FALSE, TRUE}.

-- ENTITY = SPECIFICATION DE L'INTERFACE (DECLARATION) DE L'OPERATEUR

entity MUX4_2 is				-- nom de l'op�rateur = MUX4_2
	port(						-- liste de d�clarations des signaux de l'interface
		s: 	in		Std_Logic_Vector(3 downto 0);	-- entr�e s � 4 bit : commande de s�lection
		x0: in  	Std_Logic_Vector(3 downto 0);	-- entr�e x0 � 4 bit : donn�e n�0
		x1: in		Std_Logic_Vector(3 downto 0);	-- entr�e x1 � 4 bit : donn�e n�1
		y:	buffer	Std_Logic_Vector(3 downto 0));	-- sortie rebouclable y � 4  bit : donn�e multiplex�e
end entity;

-- ARCHITECTURE = SPECIFICATION DU COMPORTEMENT (DEFINITION) DE L'OPERATION

architecture MUX4_2_arch of MUX4_2 is	-- lie l'architecture � l'entit� MUX1_2

begin

y <= x1 when s ='1' else x0;	-- branche y sur x0 * /s + x1 * s
							-- (conditionnelle concurrente)
end architecture;
