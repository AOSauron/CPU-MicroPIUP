-- Fichier : muxn_4.vhd
-- Auteur : GARCIA Guillaume & SOCHALA Antoine

-- MULTIPLEXEUR à 4 entrées de N bits

library ieee;				-- importe le bibliothèque "ieee"

use ieee.std_logic_1164.all;-- rend visible "tous" les éléments
							-- du paquetage "std_logic_1164"
							-- de la bibliothèque "ieee"
							-- dont le type Std_Logic qui modélise qualitativement
							-- la valeur d'une borne électrique (0, 1, Z, - ...) ;
							-- type Bit={0, 1} , type Boolean = {FALSE, TRUE}.

-- ENTITY = SPECIFICATION DE L'INTERFACE (DECLARATION) DE L'OPERATEUR

entity MUXN_4 is				-- nom de l'opérateur = MUXN_4
	generic (N : Integer := 4);	-- paramètre N bits
	port(						-- liste de déclarations des signaux de l'interface
		s: 	in		Std_Logic_Vector(1 downto 0);	-- entrée s à 2 bits : commande de sélection
		x0: in  	Std_Logic_Vector(N-1 downto 0);	-- entrée x0 à N bit : donnée n°0
		x1: in		Std_Logic_Vector(N-1 downto 0);	-- entrée x1 à N bit : donnée n°1
		x2: in  	Std_Logic_Vector(N-1 downto 0);	-- entrée x2 à N bit : donnée n°2
		x3: in		Std_Logic_Vector(N-1 downto 0);	-- entrée x3 à N bit : donnée n°3
		y:	buffer	Std_Logic_Vector(N-1 downto 0));-- sortie rebouclable y à N  bit : donnée multiplexée
end entity;

-- ARCHITECTURE = SPECIFICATION DU COMPORTEMENT (DEFINITION) DE L'OPERATION

architecture MUXN_4_arch of MUXN_4 is	-- lie l'architecture à l'entité MUXN_4
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