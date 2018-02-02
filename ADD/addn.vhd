--- Additionneur a N bits ADDN
---
--- Fichier: addn.vhd
---
--- Binome: GARCIA Guillaume et SOCHALA Antoine
---
--- Questions:
---
--- Question 2.a)
--- s(1) = a(1)b(0)b(1)i + a(0)a(1)b(1)i + a(0)a(1)b(0)b(1)
---        + \a(0)\a(1)\b(0)b(1) + \a(1)b(0)\b(1)i + a(0)\a(1)\b(1)i
---        + a(0)\a(1)b(0)\b(1) + \a(0)a(1)\b(0)\b(1) + \a(0)\a(1)b(1)\i
---        + \a(1)\b(0)b(1)\i + \a(0)a(1)\b(1)\i + a(1)\b(0)\b(1)\i
---
--- Question 2.b)
--- s(1) = a(1)b(1)rc_0.CMB + \a(1)\b(1)rc_0.CMB
---       + \a(1)b(1)rc_0.CMB + a(1)\b(1)\rc_0.CMB
---
--- Question 2.c)
--- s(1) = a(1)b(1)ri_1.CMB + \a(1)\b(1)ri_1.CMB 
---      + \a(1)b(1)ri_1.CMB + a(1)\b(1)\ri_1.CMB
---
--- Question 2.d)
--- s(1) = a(1)b(1)ri_1.CMB + \a(1)\b(1)ri_1.CMB 
---      + \a(1)b(1)ri_1.CMB + a(1)\b(1)\ri_1.CMB
---
--- Question 2.e)
--- Le meilleur choix est celui minimissant le nombre de macro-cellules utilisées,
--- donc pour lequel les attributs SYNTHESIS_OFF des signaux RI et RC 
--- sont respectivement fixes a (FALSE, TRUE).
---
--- Question 4.a)
--- Le nombre de passes maximal traversees entre l'entree et la sortie est
--- determine par le nombre N de bits de l'additionneur.
---
--- Question 4.b)
--- Le delai de propagation maximal entre entree et sortie note T_PD correspond
--- au delai necessaire a l'entree d'un signal sur une broche I/O, a la traversee
--- de l'ensemble des tranches de l'additionneur et a la sortie sur une broche.
--- Le delai vaut donc : T_PD = T_io + NT_p
---
--- Question 5)
--- Selon les observations, le nombre de macro-cellules utilisees est donne par 2N.

library ieee;

use ieee.std_logic_1164.all;

entity ADDN is
	generic (N : Integer := 4);
	port(
		I:	in Std_Logic;
		A:	in Std_Logic_Vector(N - 1 downto 0);
		B:	in Std_Logic_Vector(N - 1 downto 0);
		S:	buffer Std_Logic_Vector(N - 1 downto 0);
		C:	buffer Std_Logic);
	--- Affectation pin 2 au signal d'entree I.
	--- Affectation pins 3 a 6 au signal d'entree A (4 bits).
	--- Affectation pins 11 a 14 au signal d'entee B (4 bits).
	--- attribute PIN_NUMBERS of ADDN: entity is
	--- "I:2 "
	--- & "A(0):3 A(1):4 A(2):5 A(3):6 A(4):7 " 
	--- & "B(0):11 B(1):12 B(2):13 B(3):14 B(4):15";
end entity;

architecture ADDN_arch of ADDN is
	--- Signaux internes
	signal RI: Std_Logic_Vector(N - 1 downto 0); -- Retenues entees
	signal RC: Std_Logic_Vector(N - 1 downto 0); -- Retenues sorties

	-- attribute SYNTHESIS_OFF of RI: signal is FalSE;
	-- attribute SYNTHESIS_OFF of RC: signal is TRUE;

begin
	RI(0) <= I;
	S <= A xor B xor RI;

	carry_gen: for j in 1 to N - 1 generate
		RI(j) <= RC(j - 1);
	end generate carry_gen;

	RC <= (A and B) or (A and RI) or (B and RI);
	C <= RC(N - 1);

end architecture;
