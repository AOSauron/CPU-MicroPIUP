-- Fichier : mux1_2.vhd
-- Auteur : GARCIA Guillaume & SOCHALA Antoine

-- MULTIPLEXEUR à 2 entrées de 1 bit

library ieee;					-- importe le bibliothèque "ieee"

use ieee.std_logic_1164.all;	-- rend visible "tous" les éléments
						    	-- du paquetage "std_logic_1164"
								-- de la bibliothèque "ieee"
								-- dont le type Std_Logic qui modélise qualitativement
								-- la valeur d'une borne électrique (0, 1, Z, - ...) ;
								-- type Bit={0, 1} , type Boolean = {FALSE, TRUE}.

-- ENTITY = SPECIFICATION DE L'INTERFACE (DECLARATION) DE L'OPERATEUR

entity MUX1_2 is				-- nom de l'opérateur = MUX1_2
	port(						-- liste de déclarations des signaux de l'interface
		s: 	in		Std_Logic;	-- entrée s à 1 bit : commande de sélection
		x0: in  	Std_Logic;	-- entrée x0 à 1 bit : donnée n°0
		x1: in		Std_Logic;	-- entrée x1 à 1 bit : donnée n°1
		y:	buffer	Std_Logic);	-- sortie rebouclable y à 1 bit : donnée multiplexée
end entity;

-- ARCHITECTURE = SPECIFICATION DU COMPORTEMENT (DEFINITION) DE L'OPERATION

architecture MUX1_2_arch of MUX1_2 is	-- lie l'architecture à l'entité MUX1_2
	constant TPD: Time := 15 ns;  			-- TPD est bien un délai
begin

y <= (x0 and not s) or (x1 and s) after TPD;	-- branche y sur x0 * /s + x1 * s
												-- (affectation concurrente)
												-- parenthèses car opérateur sans priorité !
												-- TPD est un délai 
end architecture;
