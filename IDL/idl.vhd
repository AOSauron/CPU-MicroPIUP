-- Fichier idl.vhd
-- Auteur : GARCIA Guillaume & JAMET Alexandre


-- =========================================================
--  Décodeur d'instructions RISC
-- =========================================================
library ieee;
use ieee.std_logic_1164.all;

use work.basic_pack.all; -- use the BASIC_PACK package from the WORK (default) library
use work.mic_pack.all;   -- use the MIC_PACK package from the WORK (default) library
use work.idl_pack.all;   -- use the IDL_PACK package from the WORK (default) library

entity INSTRUCTION_DECODER_LOGIC is
    port (
        ic:    in     DByte;    -- code d'instruction
        cycle: in     Triad;    -- micro-instruction step (i.e. n° cycle dans l'instruction)
		mic:   buffer Mic_Type  -- code de micro-instruction
		);
attribute SUM_SPLIT of mic: signal is CASCADED; -- saves one cell if number of products > 16
end entity;

architecture idl_arc of INSTRUCTION_DECODER_LOGIC is


-- Déclaration des alias de champs d'instructions pour chaque groupe de format

-- Format I 
alias f1_tag:  Wire          is ic(15);
alias f1_op3:  Triad         is ic(14 downto 12);       -- OPeration 3 opérandes
alias f1_crsa: Selector_Type is ic(ALPHA-1+8 downto 8); -- Registre Source A
alias f1_crsb: Selector_Type is ic(ALPHA-1+4 downto 4); -- Registre Source B
alias f1_crd:  Selector_Type is ic(ALPHA-1 downto 0);   -- Registre Destination

-- Format II 
alias f2_op2:  Nibble        is ic(11 downto 8);        -- Operation 2 opérandes
alias f2_tag:  Nibble        is ic(15 downto 12);
alias f2_crd:  Selector_Type is ic(ALPHA-1 downto 0);   -- Registre destination
alias f2_crs:  Selector_Type is ic(ALPHA-1+4 downto 4); -- Registre Source

-- Format III
alias f3_type:  Pair          is ic(13 downto 12);         -- type operande
alias f3_tag:   Pair          is ic(15 downto 14);         -- tag
alias f3_d:     Wire          is ic(7);                    -- direction
alias f3_cra:   Selector_Type is ic(ALPHA-1+8 downto 0+8); -- registre A
alias f3_mode:  Triad         is ic(6 downto 4);           -- mode d'adressage
alias f3_crb:   Selector_Type is ic(ALPHA-1 downto 0);     -- registre B

-- Format IV
alias f4_cc  : Nibble        is ic(11 downto 8);
alias f4_tag : Nibble        is ic(15 downto 12);
alias f4_mode: Triad         is ic(6 downto 4);
alias f4_cr  : Selector_Type is ic(ALPHA-1 downto 0);

-- Format V
alias f5_tag : Pentad        is ic(15 downto 11);
alias f5_op1 : Triad         is ic(10 downto 8);
alias f5_mode: Triad         is ic(6 downto 4);
alias f5_cr  : Selector_Type is ic(ALPHA-1 downto 0);

-- Format VI
alias f6_op0:  Triad is ic(10 downto 8);

-- Format VII
alias f7_tag:  Triad  is ic (15 downto 13);
alias f7_opq:  Wire   is ic(12);
alias f7_cr :  Selector_Type is ic(ALPHA-1+8 downto 8);
alias f7_qvc:  Byte   is ic(7 downto 0);

-- Format VIII
alias f8_tag:  Nibble is ic(15 downto 12);
alias f8_cc:   Nibble is ic(11 downto 8);
alias f8_disp: Byte   is ic(7 downto 0);


signal fc: Nibble;
attribute SYNTHESIS_OFF of fc: signal is TRUE;

begin
                                 
-------------------------------------------
-- FORMAT DETECTOR: DéTERMINATION DU FORMAT
-------------------------------------------

fc <=
    F1_CODE
        when (ic and F1_MASK) = F1_MARK else
    F2_CODE
        when (ic and F2_MASK) = F2_MARK else
    F3_CODE
        when (((ic and F3_MASK) = F3_MARK1)
           or ((ic and F3_MASK) = F3_MARK2) 
           or ((ic and F3_MASK) = F3_MARK3))
	  	else
    F4_CODE
	    when (ic and F4_MASK) = F4_MARK else
    F5_CODE
	    when (ic and F5_MASK) = F5_MARK else
    F6_CODE
	    when (ic and F6_MASK) = F6_MARK else
    F7_CODE
	    when (ic and F7_MASK) = F7_MARK else
    F8_CODE
	    when (ic and F8_MASK) = F8_MARK else
    FC_ERROR;

----------------------------------------------------------------
-- MIC GENERATOR: construction de la micro-instruction
----------------------------------------------------------------
--

mic_gen_proc: process (fc, cycle, ic,
    f1_op3, f1_crsa, f1_crsb, f1_crd, f2_op2, f2_crs, f2_crd, 
    f3_mode, f3_d, f3_type, f3_cra, f3_crb,
    f4_cc, f4_mode, f4_cr, f5_op1, f5_mode, f5_cr, 
    f6_op0, f7_opq, f7_cr, f7_qvc, f8_cc, f8_disp)      -- processus "combinatoire" déclenché
                                           				-- si l'une des entrées change;
variable micv: Mic_Type := MIC_ERROR;      				-- code de microinstruction en construction

begin

-- Instructions du GROUPE 1
if fc = F1_CODE then
	if f1_op3 = F1_OP3_ADD or f1_op3 = F1_OP3_SUB or f1_op3 = F1_OP3_ADC or f1_op3 = F1_OP3_AND or f1_op3 = F1_OP3_OR or f1_op3 = F1_OP3_XOR then
		-- ALSU
		micv.alsu_op 	:= "00" & f1_op3  ; -- concaténation du code d'opération avec le préfixe "00" -- NOCARE ADD ADC SUB NEG AND OR XOR NOT SRL SRA RRC PSB LDB STB EXT SWP RLB
		micv.alsu_ais 	:= ALSU_AIS_OA    ; -- PC  OA  SR ZERO NOCARE
		micv.alsu_bis 	:= ALSU_BIS_OB    ;	-- OB  DBUS  QV  UV  NOCARE
		micv.alsu_uvc 	:= ALSU_UVC_NOCARE; -- 0  1  2  3  NOCARE
		-- RF
        micv.rf_oas     := f1_crsa        ; -- R0  R1  R2  R3  SP  NOCARE
        micv.rf_obs     := f1_crsb        ; -- R0  R1  R2  R3  SP  NOCARE
        micv.rf_ins     := f1_crd         ; -- R0  R1  R2  R3  SP  NOCARE
        micv.rf_L       := RF_L_LOAD  	  ; -- HOLD  LOAD
		-- BUS
        micv.abus_s     := ABUS_S_PC      ; -- PC    OA (or OB depending on architecture) NOCARE
        micv.cbus_typ   := CBUS_TYP_WORD  ; -- WORD  BYTE   NOCARE
        micv.cbus_wrt   := CBUS_WRT_READ  ; -- READ    WRITE    NOCARE
        micv.cbus_str   := CBUS_STR_USE   ; -- RELEASE   USE
		-- CTRL
        micv.sr_L       := SR_L_LOAD      ; -- HOLD   LOAD
        micv.pc_i       := PC_I_INC       ; -- NOINC  INC   NOCARE
        micv.bc_cc      := BC_CC_NV       ; -- NV AL EQ NE GE LE GT LW AE BE AB BL VS VC NS NC
        micv.ir_L       := IR_L_LOAD      ; -- HOLD   LOAD
        micv.msg        := MSG_OK         ; -- OK   ILLEGAL_INSTRUCTION
        micv.next_cycle := CYCLE_0        ; -- NOCARE  0 1 2 3 4 5 6 7
	else 
		micv := MIC_ERROR;
	end if;

-- Instructions du GROUPE 2
elsif fc = F2_CODE then
 	if f2_op2 = F2_OP2_NOT or f2_op2 = F2_OP2_NEG or f2_op2 = F2_OP2_SRL or f2_op2 = F2_OP2_SRA or f2_op2 = F2_OP2_RRC or f2_op2 = F2_OP2_SWB then
 		-- ALSU
		micv.alsu_op 	:= "1" & f2_op2   ; -- concaténation du code d'opération avec le préfixe "1" -- NOCARE ADD ADC SUB NEG AND OR XOR NOT SRL SRA RRC PSB LDB STB EXT SWP RLB
		micv.alsu_ais 	:= ALSU_AIS_NOCARE; -- PC  OA  SR ZERO NOCARE
		micv.alsu_bis 	:= ALSU_BIS_OB    ;	-- OB  DBUS  QV  UV  NOCARE
		micv.alsu_uvc 	:= ALSU_UVC_NOCARE; -- 0  1  2  3  NOCARE
		-- RF
        micv.rf_oas     := RF_OAS_NOCARE  ; -- R0  R1  R2  R3  SP  NOCARE
        micv.rf_obs     := f2_crs         ; -- R0  R1  R2  R3  SP  NOCARE
        micv.rf_ins     := f2_crd         ; -- R0  R1  R2  R3  SP  NOCARE
        micv.rf_L       := RF_L_LOAD  	  ; -- HOLD  LOAD
		-- BUS
        micv.abus_s     := ABUS_S_PC      ; -- PC    OA (or OB depending on architecture) NOCARE
        micv.cbus_typ   := CBUS_TYP_WORD  ; -- WORD  BYTE   NOCARE
        micv.cbus_wrt   := CBUS_WRT_READ  ; -- READ    WRITE    NOCARE
        micv.cbus_str   := CBUS_STR_USE   ; -- RELEASE   USE
		-- CTRL
        micv.sr_L       := SR_L_LOAD      ; -- HOLD   LOAD
        micv.pc_i       := PC_I_INC       ; -- NOINC  INC   NOCARE
        micv.bc_cc      := BC_CC_NV       ; -- NV AL EQ NE GE LE GT LW AE BE AB BL VS VC NS NC
        micv.ir_L       := IR_L_LOAD      ; -- HOLD   LOAD
        micv.msg        := MSG_OK         ; -- OK   ILLEGAL_INSTRUCTION
        micv.next_cycle := CYCLE_0        ; -- NOCARE  0 1 2 3 4 5 6 7
	else 
		micv := MIC_ERROR;
	end if;

-- Instructions du GROUPE 3
elsif fc = F3_CODE then
 	if f3_d = F3_D_LD then					  -- LOAD

		if f3_mode = F3_MODE_INDIRECT then    -- MODE INDIRECT (2 cycles)
			if cycle = CYCLE_0 then 		  -- CYCLE 0
		 		-- ALSU
				micv.alsu_op 	:= ALSU_OP_PSB    ; -- NOCARE ADD ADC SUB NEG AND OR XOR NOT SRL SRA RRC PSB LDB STB EXT SWP RLB
				micv.alsu_ais 	:= ALSU_AIS_NOCARE; -- PC  OA  SR ZERO NOCARE
				micv.alsu_bis 	:= ALSU_BIS_DBUS  ;	-- OB  DBUS  QV  UV  NOCARE
				micv.alsu_uvc 	:= ALSU_UVC_NOCARE; -- 0  1  2  3  NOCARE
				-- RF
		        micv.rf_oas     := RF_OAS_NOCARE  ; -- R0  R1  R2  R3  SP  NOCARE
		        micv.rf_obs     := f3_crb         ; -- R0  R1  R2  R3  SP  NOCARE
		        micv.rf_ins     := f3_cra         ; -- R0  R1  R2  R3  SP  NOCARE
		        micv.rf_L       := RF_L_LOAD  	  ; -- HOLD  LOAD
				-- BUS
		        micv.abus_s     := ABUS_S_OB      ; -- PC    OA (or OB depending on architecture) NOCARE
		        micv.cbus_typ   := CBUS_TYP_WORD  ; -- WORD  BYTE   NOCARE
		        micv.cbus_wrt   := CBUS_WRT_READ  ; -- READ    WRITE    NOCARE
		        micv.cbus_str   := CBUS_STR_USE   ; -- RELEASE   USE
				-- CTRL
		        micv.sr_L       := SR_L_LOAD      ; -- HOLD   LOAD
		        micv.pc_i       := PC_I_NOINC     ; -- NOINC  INC   NOCARE
		        micv.bc_cc      := BC_CC_NV       ; -- NV AL EQ NE GE LE GT LW AE BE AB BL VS VC NS NC
		        micv.ir_L       := IR_L_HOLD      ; -- HOLD   LOAD
		        micv.msg        := MSG_OK         ; -- OK   ILLEGAL_INSTRUCTION
		        micv.next_cycle := CYCLE_1        ; -- NOCARE  0 1 2 3 4 5 6 7

			elsif cycle = CYCLE_1 then 		  -- CYCLE 1
				-- ALSU
				micv.alsu_op 	:= ALSU_OP_NOCARE ; -- NOCARE ADD ADC SUB NEG AND OR XOR NOT SRL SRA RRC PSB LDB STB EXT SWP RLB
				micv.alsu_ais 	:= ALSU_AIS_NOCARE; -- PC  OA  SR ZERO NOCARE
				micv.alsu_bis 	:= ALSU_BIS_NOCARE;	-- OB  DBUS  QV  UV  NOCARE
				micv.alsu_uvc 	:= ALSU_UVC_NOCARE; -- 0  1  2  3  NOCARE
				-- RF
		        micv.rf_oas     := RF_OAS_NOCARE  ; -- R0  R1  R2  R3  SP  NOCARE
		        micv.rf_obs     := RF_OBS_NOCARE  ; -- R0  R1  R2  R3  SP  NOCARE
		        micv.rf_ins     := RF_INS_NOCARE  ; -- R0  R1  R2  R3  SP  NOCARE
		        micv.rf_L       := RF_L_HOLD  	  ; -- HOLD  LOAD
				-- BUS
		        micv.abus_s     := ABUS_S_PC      ; -- PC    OA (or OB depending on architecture) NOCARE
		        micv.cbus_typ   := CBUS_TYP_WORD  ; -- WORD  BYTE   NOCARE
		        micv.cbus_wrt   := CBUS_WRT_READ  ; -- READ    WRITE    NOCARE
		        micv.cbus_str   := CBUS_STR_USE   ; -- RELEASE   USE
				-- CTRL
		        micv.sr_L       := SR_L_LOAD      ; -- HOLD   LOAD
		        micv.pc_i       := PC_I_INC       ; -- NOINC  INC   NOCARE
		        micv.bc_cc      := BC_CC_NV       ; -- NV AL EQ NE GE LE GT LW AE BE AB BL VS VC NS NC
		        micv.ir_L       := IR_L_LOAD      ; -- HOLD   LOAD
		        micv.msg        := MSG_OK         ; -- OK   ILLEGAL_INSTRUCTION
		        micv.next_cycle := CYCLE_0        ; -- NOCARE  0 1 2 3 4 5 6 7
			else
		  		micv := MIC_ERROR;
			end if;

		elsif f3_mode = F3_MODE_IMMEDIATE then    -- MODE IMMEDIAT (2 cycles)
			if cycle = CYCLE_0 then 		  	  -- CYCLE 0
		 		-- ALSU
				micv.alsu_op 	:= ALSU_OP_PSB    ; -- NOCARE ADD ADC SUB NEG AND OR XOR NOT SRL SRA RRC PSB LDB STB EXT SWP RLB
				micv.alsu_ais 	:= ALSU_AIS_NOCARE; -- PC  OA  SR ZERO NOCARE
				micv.alsu_bis 	:= ALSU_BIS_DBUS  ;	-- OB  DBUS  QV  UV  NOCARE
				micv.alsu_uvc 	:= ALSU_UVC_NOCARE; -- 0  1  2  3  NOCARE
				-- RF
		        micv.rf_oas     := RF_OAS_NOCARE  ; -- R0  R1  R2  R3  SP  NOCARE
		        micv.rf_obs     := RF_OBS_NOCARE  ; -- R0  R1  R2  R3  SP  NOCARE
		        micv.rf_ins     := f3_cra         ; -- R0  R1  R2  R3  SP  NOCARE
		        micv.rf_L       := RF_L_LOAD  	  ; -- HOLD  LOAD
				-- BUS
		        micv.abus_s     := ABUS_S_PC      ; -- PC    OA (or OB depending on architecture) NOCARE
		        micv.cbus_typ   := CBUS_TYP_WORD  ; -- WORD  BYTE   NOCARE
		        micv.cbus_wrt   := CBUS_WRT_READ  ; -- READ    WRITE    NOCARE
		        micv.cbus_str   := CBUS_STR_USE   ; -- RELEASE   USE
				-- CTRL
		        micv.sr_L       := SR_L_LOAD      ; -- HOLD   LOAD
		        micv.pc_i       := PC_I_INC       ; -- NOINC  INC   NOCARE
		        micv.bc_cc      := BC_CC_NV       ; -- NV AL EQ NE GE LE GT LW AE BE AB BL VS VC NS NC
		        micv.ir_L       := IR_L_HOLD      ; -- HOLD   LOAD
		        micv.msg        := MSG_OK         ; -- OK   ILLEGAL_INSTRUCTION
		        micv.next_cycle := CYCLE_1        ; -- NOCARE  0 1 2 3 4 5 6 7

			elsif cycle = CYCLE_1 then 			 -- CYCLE 1
				-- ALSU
				micv.alsu_op 	:= ALSU_OP_NOCARE ; -- NOCARE ADD ADC SUB NEG AND OR XOR NOT SRL SRA RRC PSB LDB STB EXT SWP RLB
				micv.alsu_ais 	:= ALSU_AIS_NOCARE; -- PC  OA  SR ZERO NOCARE
				micv.alsu_bis 	:= ALSU_BIS_NOCARE;	-- OB  DBUS  QV  UV  NOCARE
				micv.alsu_uvc 	:= ALSU_UVC_NOCARE; -- 0  1  2  3  NOCARE
				-- RF
		        micv.rf_oas     := RF_OAS_NOCARE  ; -- R0  R1  R2  R3  SP  NOCARE
		        micv.rf_obs     := RF_OBS_NOCARE  ; -- R0  R1  R2  R3  SP  NOCARE
		        micv.rf_ins     := RF_INS_NOCARE  ; -- R0  R1  R2  R3  SP  NOCARE
		        micv.rf_L       := RF_L_HOLD  	  ; -- HOLD  LOAD
				-- BUS
		        micv.abus_s     := ABUS_S_PC      ; -- PC    OA (or OB depending on architecture) NOCARE
		        micv.cbus_typ   := CBUS_TYP_WORD  ; -- WORD  BYTE   NOCARE
		        micv.cbus_wrt   := CBUS_WRT_READ  ; -- READ    WRITE    NOCARE
		        micv.cbus_str   := CBUS_STR_USE   ; -- RELEASE   USE
				-- CTRL
		        micv.sr_L       := SR_L_LOAD      ; -- HOLD   LOAD
		        micv.pc_i       := PC_I_INC       ; -- NOINC  INC   NOCARE
		        micv.bc_cc      := BC_CC_NV       ; -- NV AL EQ NE GE LE GT LW AE BE AB BL VS VC NS NC
		        micv.ir_L       := IR_L_LOAD      ; -- HOLD   LOAD
		        micv.msg        := MSG_OK         ; -- OK   ILLEGAL_INSTRUCTION
		        micv.next_cycle := CYCLE_0        ; -- NOCARE  0 1 2 3 4 5 6 7
			else
		  		micv := MIC_ERROR;
			end if;

		elsif f3_mode = F3_MODE_REGISTER then     -- MODE REGISTRE (1 cycle)
	 		-- ALSU
			micv.alsu_op 	:= ALSU_OP_PSB    ; -- NOCARE ADD ADC SUB NEG AND OR XOR NOT SRL SRA RRC PSB LDB STB EXT SWP RLB
			micv.alsu_ais 	:= ALSU_AIS_NOCARE; -- PC  OA  SR ZERO NOCARE
			micv.alsu_bis 	:= ALSU_BIS_OB    ;	-- OB  DBUS  QV  UV  NOCARE
			micv.alsu_uvc 	:= ALSU_UVC_NOCARE; -- 0  1  2  3  NOCARE
			-- RF
	        micv.rf_oas     := RF_OAS_NOCARE  ; -- R0  R1  R2  R3  SP  NOCARE
	        micv.rf_obs     := f3_crb         ; -- R0  R1  R2  R3  SP  NOCARE
	        micv.rf_ins     := f3_cra         ; -- R0  R1  R2  R3  SP  NOCARE
	        micv.rf_L       := RF_L_LOAD  	  ; -- HOLD  LOAD
			-- BUS
	        micv.abus_s     := ABUS_S_PC      ; -- PC    OA (or OB depending on architecture) NOCARE
	        micv.cbus_typ   := CBUS_TYP_WORD  ; -- WORD  BYTE   NOCARE
	        micv.cbus_wrt   := CBUS_WRT_READ  ; -- READ    WRITE    NOCARE
	        micv.cbus_str   := CBUS_STR_USE   ; -- RELEASE   USE
			-- CTRL
	        micv.sr_L       := SR_L_LOAD      ; -- HOLD   LOAD
	        micv.pc_i       := PC_I_INC       ; -- NOINC  INC   NOCARE
	        micv.bc_cc      := BC_CC_NV       ; -- NV AL EQ NE GE LE GT LW AE BE AB BL VS VC NS NC
	        micv.ir_L       := IR_L_LOAD      ; -- HOLD   LOAD
	        micv.msg        := MSG_OK         ; -- OK   ILLEGAL_INSTRUCTION
	        micv.next_cycle := CYCLE_0        ; -- NOCARE  0 1 2 3 4 5 6 7
		else
			micv := MIC_ERROR;
		end if;

	elsif f3_d = F3_D_ST then				    -- STORE

		if f3_mode = F3_MODE_INDIRECT then      -- MODE INDIRECT (2 cycles)
			if cycle = CYCLE_0 then 		    -- CYCLE 0
		 		-- ALSU
				micv.alsu_op 	:= ALSU_OP_OR     ; -- cOn veut faire un PASS A => on fait un OR de A avec 0
				micv.alsu_ais 	:= f3_cra         ; -- PC  OA  SR ZERO NOCARE
				micv.alsu_bis 	:= ALSU_BIS_UV    ;	-- OB  DBUS  QV  UV  NOCARE
				micv.alsu_uvc 	:= ALSU_UVC_0     ; -- 0  1  2  3  NOCARE
				-- RF
		        micv.rf_oas     := f3_cra  		  ; -- R0  R1  R2  R3  SP  NOCARE
		        micv.rf_obs     := f3_crb         ; -- R0  R1  R2  R3  SP  NOCARE
		        micv.rf_ins     := RF_INS_NOCARE  ; -- R0  R1  R2  R3  SP  NOCARE
		        micv.rf_L       := RF_L_HOLD  	  ; -- HOLD  LOAD
				-- BUS
		        micv.abus_s     := ABUS_S_OB      ; -- PC    OA (or OB depending on architecture) NOCARE
		        micv.cbus_typ   := CBUS_TYP_WORD  ; -- WORD  BYTE   NOCARE
		        micv.cbus_wrt   := CBUS_WRT_WRITE ; -- READ    WRITE    NOCARE
		        micv.cbus_str   := CBUS_STR_USE   ; -- RELEASE   USE
				-- CTRL
		        micv.sr_L       := SR_L_LOAD      ; -- HOLD   LOAD
		        micv.pc_i       := PC_I_NOINC     ; -- NOINC  INC   NOCARE
		        micv.bc_cc      := BC_CC_NV       ; -- NV AL EQ NE GE LE GT LW AE BE AB BL VS VC NS NC
		        micv.ir_L       := IR_L_HOLD      ; -- HOLD   LOAD
		        micv.msg        := MSG_OK         ; -- OK   ILLEGAL_INSTRUCTION
		        micv.next_cycle := CYCLE_1        ; -- NOCARE  0 1 2 3 4 5 6 7

			elsif cycle = CYCLE_1 then 		  -- CYCLE 1
				-- ALSU
				micv.alsu_op 	:= ALSU_OP_NOCARE ; -- NOCARE ADD ADC SUB NEG AND OR XOR NOT SRL SRA RRC PSB LDB STB EXT SWP RLB
				micv.alsu_ais 	:= ALSU_AIS_NOCARE; -- PC  OA  SR ZERO NOCARE
				micv.alsu_bis 	:= ALSU_BIS_NOCARE;	-- OB  DBUS  QV  UV  NOCARE
				micv.alsu_uvc 	:= ALSU_UVC_NOCARE; -- 0  1  2  3  NOCARE
				-- RF
		        micv.rf_oas     := RF_OAS_NOCARE  ; -- R0  R1  R2  R3  SP  NOCARE
		        micv.rf_obs     := RF_OBS_NOCARE  ; -- R0  R1  R2  R3  SP  NOCARE
		        micv.rf_ins     := RF_INS_NOCARE  ; -- R0  R1  R2  R3  SP  NOCARE
		        micv.rf_L       := RF_L_HOLD  	  ; -- HOLD  LOAD
				-- BUS
		        micv.abus_s     := ABUS_S_PC      ; -- PC    OA (or OB depending on architecture) NOCARE
		        micv.cbus_typ   := CBUS_TYP_WORD  ; -- WORD  BYTE   NOCARE
		        micv.cbus_wrt   := CBUS_WRT_READ  ; -- READ    WRITE    NOCARE
		        micv.cbus_str   := CBUS_STR_USE   ; -- RELEASE   USE
				-- CTRL
		        micv.sr_L       := SR_L_LOAD      ; -- HOLD   LOAD
		        micv.pc_i       := PC_I_INC       ; -- NOINC  INC   NOCARE
		        micv.bc_cc      := BC_CC_NV       ; -- NV AL EQ NE GE LE GT LW AE BE AB BL VS VC NS NC
		        micv.ir_L       := IR_L_LOAD      ; -- HOLD   LOAD
		        micv.msg        := MSG_OK         ; -- OK   ILLEGAL_INSTRUCTION
		        micv.next_cycle := CYCLE_0        ; -- NOCARE  0 1 2 3 4 5 6 7
			else
		  		micv := MIC_ERROR;
			end if;
		else 
			micv := MIC_ERROR;
		end if;
	else 
		micv := MIC_ERROR;
	end if;

-- Instructions du GROUPE 4 -- PAS SUPPORTEES
elsif fc = F4_CODE then
	micv := MIC_ERROR;

-- Instructions du GROUPE 5
elsif fc = F5_CODE then
	if f5_op1 = F5_OP1_MPC then				 		  	-- MPC

		if f5_mode = F5_MODE_REGISTER then      		-- MODE REGISTRE (1 cycle)
			-- ALSU
			micv.alsu_op 	:= ALSU_OP_OR     ; -- cOn veut faire un PASS A => on fait un OR de A avec 0
			micv.alsu_ais 	:= ALSU_AIS_PC    ; -- PC  OA  SR ZERO NOCARE
			micv.alsu_bis 	:= ALSU_BIS_UV    ;	-- OB  DBUS  QV  UV  NOCARE
			micv.alsu_uvc 	:= ALSU_UVC_0     ; -- 0  1  2  3  NOCARE
			-- RF
	        micv.rf_oas     := RF_OAS_NOCARE  ; -- R0  R1  R2  R3  SP  NOCARE
	        micv.rf_obs     := RF_OBS_NOCARE  ; -- R0  R1  R2  R3  SP  NOCARE
	        micv.rf_ins     := f5_cr  		  ; -- R0  R1  R2  R3  SP  NOCARE
	        micv.rf_L       := RF_L_LOAD 	  ; -- HOLD  LOAD
			-- BUS
	        micv.abus_s     := ABUS_S_PC      ; -- PC    OA (or OB depending on architecture) NOCARE
	        micv.cbus_typ   := CBUS_TYP_WORD  ; -- WORD  BYTE   NOCARE
	        micv.cbus_wrt   := CBUS_WRT_WRITE ; -- READ    WRITE    NOCARE
	        micv.cbus_str   := CBUS_STR_USE   ; -- RELEASE   USE
			-- CTRL
	        micv.sr_L       := SR_L_LOAD      ; -- HOLD   LOAD
	        micv.pc_i       := PC_I_INC       ; -- NOINC  INC   NOCARE
	        micv.bc_cc      := BC_CC_NV       ; -- NV AL EQ NE GE LE GT LW AE BE AB BL VS VC NS NC
	        micv.ir_L       := IR_L_LOAD      ; -- HOLD   LOAD
	        micv.msg        := MSG_OK         ; -- OK   ILLEGAL_INSTRUCTION
	        micv.next_cycle := CYCLE_0        ; -- NOCARE  0 1 2 3 4 5 6 7
		else
			micv := MIC_ERROR;                  		-- Aucun autre mode supporté
		end if;

	elsif f5_op1 = F5_OP1_JEA then				 		-- JEA

		if f5_mode = F5_MODE_INDIRECT then      		-- MODE INDIRECT (1 cycle)
			-- ALSU
			micv.alsu_op 	:= ALSU_OP_ADD    ; -- NOCARE ADD ADC SUB NEG AND OR XOR NOT SRL SRA RRC PSB LDB STB EXT SWP RLB
			micv.alsu_ais 	:= ALSU_AIS_OA    ; -- PC  OA  SR ZERO NOCARE
			micv.alsu_bis 	:= ALSU_BIS_UV    ;	-- OB  DBUS  QV  UV  NOCARE
			micv.alsu_uvc 	:= ALSU_UVC_2     ; -- 0  1  2  3  NOCARE
			-- RF
	        micv.rf_oas     := f5_cr		  ; -- R0  R1  R2  R3  SP  NOCARE -- Sert pour l'ALU (PC)
	        micv.rf_obs     := f5_cr		  ; -- R0  R1  R2  R3  SP  NOCARE -- Sert pour charger (IR)
	        micv.rf_ins     := RF_INS_NOCARE  ; -- R0  R1  R2  R3  SP  NOCARE
	        micv.rf_L       := RF_L_LOAD 	  ; -- HOLD  LOAD
			-- BUS
	        micv.abus_s     := ABUS_S_OA      ; -- PC    OA (or OB depending on architecture) NOCARE
	        micv.cbus_typ   := CBUS_TYP_NOCARE; -- WORD  BYTE   NOCARE
	        micv.cbus_wrt   := CBUS_WRT_NOCARE; -- READ    WRITE    NOCARE
	        micv.cbus_str   := CBUS_STR_RELEASE; -- RELEASE   USE
			-- CTRL
	        micv.sr_L       := SR_L_HOLD      ; -- HOLD   LOAD
	        micv.pc_i       := PC_I_NOINC     ; -- NOINC  INC   NOCARE
	        micv.bc_cc      := BC_CC_AL       ; -- NV AL EQ NE GE LE GT LW AE BE AB BL VS VC NS NC -- ALWAYS LOADER L'ADRESSE !
	        micv.ir_L       := IR_L_LOAD      ; -- HOLD   LOAD
	        micv.msg        := MSG_OK         ; -- OK   ILLEGAL_INSTRUCTION
	        micv.next_cycle := CYCLE_0        ; -- NOCARE  0 1 2 3 4 5 6 7
		else
			micv := MIC_ERROR;                  		-- Aucun autre mode supporté
		end if;
	else
		micv := MIC_ERROR; 								-- Pas d'autres instructions supportées
	end if;

-- Instructions du GROUPE 6
elsif fc = F6_CODE then
	if f6_op0 = F6_OP0_NOP then				 	  		-- NOP
		-- ALSU
		micv.alsu_op 	:= ALSU_OP_NOCARE ; -- NOCARE ADD ADC SUB NEG AND OR XOR NOT SRL SRA RRC PSB LDB STB EXT SWP RLB
		micv.alsu_ais 	:= ALSU_AIS_NOCARE; -- PC  OA  SR ZERO NOCARE
		micv.alsu_bis 	:= ALSU_BIS_NOCARE;	-- OB  DBUS  QV  UV  NOCARE
		micv.alsu_uvc 	:= ALSU_UVC_NOCARE; -- 0  1  2  3  NOCARE
		-- RF
        micv.rf_oas     := RF_OAS_NOCARE  ; -- R0  R1  R2  R3  SP  NOCARE
        micv.rf_obs     := RF_OBS_NOCARE  ; -- R0  R1  R2  R3  SP  NOCARE
        micv.rf_ins     := RF_INS_NOCARE  ; -- R0  R1  R2  R3  SP  NOCARE
        micv.rf_L       := RF_L_HOLD  	  ; -- HOLD  LOAD
		-- BUS
        micv.abus_s     := ABUS_S_PC      ; -- PC    OA (or OB depending on architecture) NOCARE
        micv.cbus_typ   := CBUS_TYP_NOCARE; -- WORD  BYTE   NOCARE
        micv.cbus_wrt   := CBUS_WRT_NOCARE; -- READ    WRITE    NOCARE
        micv.cbus_str   := CBUS_STR_RELEASE; -- RELEASE   USE
		-- CTRL
        micv.sr_L       := SR_L_HOLD      ; -- HOLD   LOAD
        micv.pc_i       := PC_I_INC       ; -- NOINC  INC   NOCARE
        micv.bc_cc      := BC_CC_NV       ; -- NV AL EQ NE GE LE GT LW AE BE AB BL VS VC NS NC
        micv.ir_L       := IR_L_LOAD      ; -- HOLD   LOAD
        micv.msg        := MSG_OK         ; -- OK   ILLEGAL_INSTRUCTION
        micv.next_cycle := CYCLE_0        ; -- NOCARE  0 1 2 3 4 5 6 7
	else
		micv := MIC_ERROR; 								-- Pas d'autres instructions supportées
	end if;

-- Instructions du GROUPE 7
elsif fc = F7_CODE then
	if f7_opq = F7_OPQ_ADQ then				 		  	  -- ADQ
		-- ALSU
		micv.alsu_op 	:= ALSU_OP_ADD    ; -- NOCARE ADD ADC SUB NEG AND OR XOR NOT SRL SRA RRC PSB LDB STB EXT SWP RLB
		micv.alsu_ais 	:= ALSU_AIS_OA    ; -- PC  OA  SR ZERO NOCARE
		micv.alsu_bis 	:= ALSU_BIS_QV    ;	-- OB  DBUS  QV  UV  NOCARE
		micv.alsu_uvc 	:= ALSU_UVC_NOCARE; -- 0  1  2  3  NOCARE
		-- RF
        micv.rf_oas     := f7_cr		  ; -- R0  R1  R2  R3  SP  NOCARE
        micv.rf_obs     := RF_OBS_NOCARE  ; -- R0  R1  R2  R3  SP  NOCARE
        micv.rf_ins     := f7_cr  		  ; -- R0  R1  R2  R3  SP  NOCARE
        micv.rf_L       := RF_L_LOAD 	  ; -- HOLD  LOAD
		-- BUS
        micv.abus_s     := ABUS_S_PC      ; -- PC    OA (or OB depending on architecture) NOCARE
        micv.cbus_typ   := CBUS_TYP_WORD  ; -- WORD  BYTE   NOCARE
        micv.cbus_wrt   := CBUS_WRT_READ  ; -- READ    WRITE    NOCARE
        micv.cbus_str   := CBUS_STR_USE	  ; -- RELEASE   USE
		-- CTRL
        micv.sr_L       := SR_L_LOAD      ; -- HOLD   LOAD
        micv.pc_i       := PC_I_INC       ; -- NOINC  INC   NOCARE
        micv.bc_cc      := BC_CC_NV       ; -- NV AL EQ NE GE LE GT LW AE BE AB BL VS VC NS NC
        micv.ir_L       := IR_L_LOAD      ; -- HOLD   LOAD
        micv.msg        := MSG_OK         ; -- OK   ILLEGAL_INSTRUCTION
        micv.next_cycle := CYCLE_0        ; -- NOCARE  0 1 2 3 4 5 6 7

	elsif f7_opq = F7_OPQ_LDQ then				 		  -- LDQ
		-- ALSU
		micv.alsu_op 	:= ALSU_OP_PSB    ; -- NOCARE ADD ADC SUB NEG AND OR XOR NOT SRL SRA RRC PSB LDB STB EXT SWP RLB
		micv.alsu_ais 	:= ALSU_AIS_NOCARE; -- PC  OA  SR ZERO NOCARE
		micv.alsu_bis 	:= ALSU_BIS_QV    ;	-- OB  DBUS  QV  UV  NOCARE
		micv.alsu_uvc 	:= ALSU_UVC_NOCARE; -- 0  1  2  3  NOCARE
		-- RF
        micv.rf_oas     := RF_OAS_NOCARE  ; -- R0  R1  R2  R3  SP  NOCARE -- Enonce nous dit f7_cr ! pk ?
        micv.rf_obs     := RF_OBS_NOCARE  ; -- R0  R1  R2  R3  SP  NOCARE
        micv.rf_ins     := f7_cr  		  ; -- R0  R1  R2  R3  SP  NOCARE
        micv.rf_L       := RF_L_LOAD 	  ; -- HOLD  LOAD
		-- BUS
        micv.abus_s     := ABUS_S_PC      ; -- PC    OA (or OB depending on architecture) NOCARE
        micv.cbus_typ   := CBUS_TYP_WORD  ; -- WORD  BYTE   NOCARE
        micv.cbus_wrt   := CBUS_WRT_READ  ; -- READ    WRITE    NOCARE
        micv.cbus_str   := CBUS_STR_USE	  ; -- RELEASE   USE
		-- CTRL
        micv.sr_L       := SR_L_LOAD      ; -- HOLD   LOAD
        micv.pc_i       := PC_I_INC       ; -- NOINC  INC   NOCARE
        micv.bc_cc      := BC_CC_NV       ; -- NV AL EQ NE GE LE GT LW AE BE AB BL VS VC NS NC
        micv.ir_L       := IR_L_LOAD      ; -- HOLD   LOAD
        micv.msg        := MSG_OK         ; -- OK   ILLEGAL_INSTRUCTION
        micv.next_cycle := CYCLE_0        ; -- NOCARE  0 1 2 3 4 5 6 7
	else
		micv := MIC_ERROR; 								-- Pas d'autres instructions supportées
	end if;

-- Instructions du GROUPE 8
elsif fc = F8_CODE then
	-- ALSU
	micv.alsu_op 	:= ALSU_OP_ADD    ; -- NOCARE ADD ADC SUB NEG AND OR XOR NOT SRL SRA RRC PSB LDB STB EXT SWP RLB
	micv.alsu_ais 	:= ALSU_AIS_PC	  ; -- PC  OA  SR ZERO NOCARE
	micv.alsu_bis 	:= ALSU_BIS_QV    ;	-- OB  DBUS  QV  UV  NOCARE
	micv.alsu_uvc 	:= ALSU_UVC_NOCARE; -- 0  1  2  3  NOCARE
	-- RF
    micv.rf_oas     := RF_OAS_NOCARE  ; -- R0  R1  R2  R3  SP  NOCARE
    micv.rf_obs     := RF_OBS_NOCARE  ; -- R0  R1  R2  R3  SP  NOCARE
    micv.rf_ins     := RF_INS_NOCARE  ; -- R0  R1  R2  R3  SP  NOCARE
    micv.rf_L       := RF_L_HOLD 	  ; -- HOLD  LOAD
	-- BUS
    micv.abus_s     := ABUS_S_PC      ; -- PC    OA (or OB depending on architecture) NOCARE
    micv.cbus_typ   := CBUS_TYP_NOCARE; -- WORD  BYTE   NOCARE
    micv.cbus_wrt   := CBUS_WRT_NOCARE; -- READ    WRITE    NOCARE
    micv.cbus_str   := CBUS_STR_RELEASE; -- RELEASE   USE
	-- CTRL
    micv.sr_L       := SR_L_HOLD      ; -- HOLD   LOAD
    micv.pc_i       := PC_I_INC       ; -- NOINC  INC   NOCARE
	if f8_cc = F8_CC_AL then				 		  	-- BAL
		micv.bc_cc      := BC_CC_AL       ; 
	elsif f8_cc = F8_CC_EQ then				 		  	-- BEQ
		micv.bc_cc      := BC_CC_EQ       ;
	elsif f8_cc = F8_CC_NE then				 		  	-- BNE
		micv.bc_cc      := BC_CC_NE       ; 
	elsif f8_cc = F8_CC_GE then				 		  	-- BGE
		micv.bc_cc      := BC_CC_GE       ; 
	elsif f8_cc = F8_CC_LE then				 		  	-- BLE
		micv.bc_cc      := BC_CC_LE       ;
	elsif f8_cc = F8_CC_GT then				 		  	-- BGT
		micv.bc_cc      := BC_CC_GT       ;
	elsif f8_cc = F8_CC_LW then				 		  	-- BLW
		micv.bc_cc      := BC_CC_LW       ;
	elsif f8_cc = F8_CC_AE then				 		  	-- BAE
		micv.bc_cc      := BC_CC_AE       ;
	elsif f8_cc = F8_CC_BE then				 		  	-- BBE
		micv.bc_cc      := BC_CC_BE       ; 
	elsif f8_cc = F8_CC_AB then				 		  	-- BAB
		micv.bc_cc      := BC_CC_AB       ; 
	elsif f8_cc = F8_CC_BL then				 		  	-- BBL
		micv.bc_cc      := BC_CC_BL       ;
	elsif f8_cc = F8_CC_VS then				 		  	-- BVS
		micv.bc_cc      := BC_CC_VS       ;
	elsif f8_cc = F8_CC_VC then				 		  	-- BVC
		micv.bc_cc      := BC_CC_VC       ; 
	elsif f8_cc = F8_CC_NS then				 		  	-- BNS
		micv.bc_cc      := BC_CC_NS       ; 
	elsif f8_cc = F8_CC_NC then				 		  	-- BNC
		micv.bc_cc      := BC_CC_NC       ;
	else				 		  
		micv := MIC_ERROR;
	end if;
    micv.ir_L       := IR_L_LOAD      ; -- HOLD   LOAD
    micv.msg        := MSG_OK         ; -- OK   ILLEGAL_INSTRUCTION
    micv.next_cycle := CYCLE_0        ; -- NOCARE  0 1 2 3 4 5 6 7

else
	micv := MIC_ERROR; 								-- Pas d'autres groupes possibles !

end if;

mic <= micv;  -- affecte le contenu de la variable micv au signal mic

end process;

end architecture;