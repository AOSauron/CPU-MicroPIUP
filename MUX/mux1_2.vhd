-- Fichier : mux1_2.vhd
-- Auteur : GARCIA Guillaume & SOCHALA Antoine

-- MULTIPLEXEUR � 2 entr�es de 1 bit

library ieee;					-- importe le biblioth�que "ieee"

use ieee.std_logic_1164.all;	-- rend visible "tous" les �l�ments
						    	-- du paquetage "std_logic_1164"
								-- de la biblioth�que "ieee"
								-- dont le type Std_Logic qui mod�lise qualitativement
								-- la valeur d'une borne �lectrique (0, 1, Z, - ...) ;
								-- type Bit={0, 1} , type Boolean = {FALSE, TRUE}.

-- ENTITY = SPECIFICATION DE L'INTERFACE (DECLARATION) DE L'OPERATEUR

entity MUX1_2 is				-- nom de l'op�rateur = MUX1_2
	port(						-- liste de d�clarations des signaux de l'interface
		s: 	in		Std_Logic;	-- entr�e s � 1 bit : commande de s�lection
		x0: in  	Std_Logic;	-- entr�e x0 � 1 bit : donn�e n�0
		x1: in		Std_Logic;	-- entr�e x1 � 1 bit : donn�e n�1
		y:	buffer	Std_Logic);	-- sortie rebouclable y � 1 bit : donn�e multiplex�e
end entity;

-- ARCHITECTURE = SPECIFICATION DU COMPORTEMENT (DEFINITION) DE L'OPERATION

architecture MUX1_2_arch of MUX1_2 is	-- lie l'architecture � l'entit� MUX1_2
	constant TPD: Time := 15 ns;  			-- TPD est bien un d�lai
begin

y <= (x0 and not s) or (x1 and s) after TPD;	-- branche y sur x0 * /s + x1 * s
												-- (affectation concurrente)
												-- parenth�ses car op�rateur sans priorit� !
												-- TPD est un d�lai 
end architecture;
