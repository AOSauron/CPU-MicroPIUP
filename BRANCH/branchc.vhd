-- Fichier : branchd.vhd
-- Auteurs : GARCIA Guillaume & SOCHALA Antoine

-- BRANCH CONTROLLER

library ieee;
use ieee.std_logic_1164.all;

entity BRANCH is								
	port(										
		NF: in	Std_Logic;						-- Negative flag
		CF: in	Std_Logic;						-- Carry flag
		VF: in	Std_Logic;						-- oVerflow flag
		ZF: in  Std_Logic;						-- Zero flag
		CC: in  Std_Logic_Vector(3 downto 0);	-- Condition code sur 4 bits (fixe)
		BR:	buffer	Std_Logic);					-- Branchement (sortie)
end entity;


architecture BRANCH_arch of BRANCH is

	-- Les 16 différentes valeures des code de conditions
	constant CC_NV : Std_Logic_Vector(3 downto 0) := "0000";	-- NV : NeVer
	constant CC_AL : Std_Logic_Vector(3 downto 0) := "0001"; 	-- AL : ALways
	constant CC_EQ : Std_Logic_Vector(3 downto 0) := "0010"; 	-- EQ : EQual
	constant CC_NE : Std_Logic_Vector(3 downto 0) := "0011";	-- NE : Not Equal
	constant CC_GE : Std_Logic_Vector(3 downto 0) := "0100";	-- GE : Greater or Equal
	constant CC_LE : Std_Logic_Vector(3 downto 0) := "0101";	-- LE : Lower or Equal
	constant CC_GT : Std_Logic_Vector(3 downto 0) := "0110";	-- GT : GreaTer
	constant CC_LW : Std_Logic_Vector(3 downto 0) := "0111";	-- LW : LoWer
	constant CC_AE : Std_Logic_Vector(3 downto 0) := "1000";	-- AE : Above or Equal
	constant CC_BE : Std_Logic_Vector(3 downto 0) := "1001";	-- BE : Below or Equal
	constant CC_AB : Std_Logic_Vector(3 downto 0) := "1010";	-- AB : ABove
	constant CC_BL : Std_Logic_Vector(3 downto 0) := "1011";	-- BL : BeLow
	constant CC_VS : Std_Logic_Vector(3 downto 0) := "1100";	-- VS : oVerflow Set
	constant CC_VC : Std_Logic_Vector(3 downto 0) := "1101";	-- VC : oVerflow Cleared
	constant CC_NS : Std_Logic_Vector(3 downto 0) := "1110";	-- NS : Negative Set
	constant CC_NC : Std_Logic_Vector(3 downto 0) := "1111";	-- NC : Negative Cleared

begin

branch_proc: process(CC)
	begin
	if (CC = CC_NV) then				-- NV
		BR <= '0';	
	elsif (CC = CC_AL) then				-- AL
		BR <= '1';
	elsif (CC = CC_EQ) then				-- EQ
		BR <= ZF;
	elsif (CC = CC_NE) then				-- NE
		BR <= not ZF;
 ------------------ Signés ---------------------
	elsif (CC = CC_GE) then				-- GE
		BR <= not (NF xor VF);
	elsif (CC = CC_LE) then				-- LE
		BR <= ZF or (NF xor VF);
	elsif (CC = CC_GT) then				-- GT
		BR <= not (ZF or (NF xor VF));
	elsif (CC = CC_LW) then				-- LW
		BR <= NF xor VF;
 ------------------ Non signés -----------------
	elsif (CC = CC_AE) then				-- AE
		BR <= not CF;
	elsif (CC = CC_BE) then				-- BE
		BR <= CF or ZF;
	elsif (CC = CC_AB) then				-- AB
		BR <= not (CF or ZF);
	elsif (CC = CC_BL) then				-- BL
		BR <= CF;
------------------------------------------------
	elsif (CC = CC_VS) then				-- VS
		BR <= VF;
	elsif (CC = CC_VC) then				-- VC
		BR <= not VF;
	elsif (CC = CC_NS) then				-- NS
		BR <= NF;
	elsif (CC = CC_NC) then				-- NC
		BR <= not NF;
   	end if;
end process;

end architecture;

----- Commentaires :

-- Equation : (16 monomes) 
--    br =
--          /cc(1) * cc(2) * /cc(3) * /nf * /vf * zf 
--        + /cc(0) * cc(2) * /cc(3) * /nf * /vf * /zf 
--        + /cc(0) * cc(1) * cc(2) * cc(3) * nf 
--        + /cc(0) * /cc(1) * cc(2) * nf * vf 
--        + /cc(0) * /cc(1) * cc(2) * cc(3) * vf 
--        + /cc(0) * cc(1) * /cc(2) * /cc(3) * zf 
--        + /cc(1) * /cc(2) * cc(3) * /cf * zf 
--        + cc(0) * cc(1) * cc(2) * cc(3) * /nf 
--        + cc(0) * cc(2) * /cc(3) * /nf * vf 
--        + cc(0) * /cc(1) * cc(2) * cc(3) * /vf 
--        + cc(0) * cc(2) * /cc(3) * nf * /vf 
--        + /cc(0) * cc(2) * nf * vf * /zf 
--        + /cc(0) * /cc(2) * cc(3) * /cf * /zf 
--        + cc(0) * /cc(2) * cc(3) * cf 
--        + cc(0) * /cc(1) * /cc(3) * zf 
--        + cc(0) * /cc(2) * /cc(3) * /zf 
--
--
-- On a donc bien 1 seule cellule utilisée :
--
--	Macrocells Used                1          256
