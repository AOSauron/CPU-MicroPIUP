-- Fichier : mux4_2.vhd
-- Auteur : GARCIA Guillaume & SOCHALA Antoine

-- MULTIPLEXEUR à 2 entrées de 4 bits

library ieee;				-- importe le bibliothèque "ieee"

use ieee.std_logic_1164.all;-- rend visible "tous" les éléments
							-- du paquetage "std_logic_1164"
							-- de la bibliothèque "ieee"
							-- dont le type Std_Logic qui modélise qualitativement
							-- la valeur d'une borne électrique (0, 1, Z, - ...) ;
							-- type Bit={0, 1} , type Boolean = {FALSE, TRUE}.

-- ENTITY = SPECIFICATION DE L'INTERFACE (DECLARATION) DE L'OPERATEUR

entity MUX4_2 is				-- nom de l'opérateur = MUX4_2
	port(						-- liste de déclarations des signaux de l'interface
		s: 	in		Std_Logic_Vector(3 downto 0);	-- entrée s à 4 bit : commande de sélection
		x0: in  	Std_Logic_Vector(3 downto 0);	-- entrée x0 à 4 bit : donnée n°0
		x1: in		Std_Logic_Vector(3 downto 0);	-- entrée x1 à 4 bit : donnée n°1
		y:	buffer	Std_Logic_Vector(3 downto 0));	-- sortie rebouclable y à 4  bit : donnée multiplexée
end entity;

-- ARCHITECTURE = SPECIFICATION DU COMPORTEMENT (DEFINITION) DE L'OPERATION

architecture MUX4_2_arch of MUX4_2 is	-- lie l'architecture à l'entité MUX1_2

begin

y <= x1 when s ='1' else x0;	-- branche y sur x0 * /s + x1 * s
							-- (conditionnelle concurrente)
end architecture;
