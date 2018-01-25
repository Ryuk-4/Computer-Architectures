	AREA myCode, READONLY, CODE
		
reset_handler
	ENTRY
		LDR R0, =3
		LDR R1, =2
		LDR R2, =6
;		R3 temp register
		EOR R4, R4 	;Result1
		EOR R5, R5	;Result2
;		R6 temp register
		EOR R6, R6
;		R7 temp register
		EOR R7, R7
;		R8 temp register

		CMP R0, R1
		;Move R0 into R8 iff R0 > R1
		MOVHI R8, R0
		;Move R1 into R0 iff R0 > R1
		MOVHI R0, R1
		;Move R8 into R1 iff R0 > R1
		MOVHI R1, R8

		CMP R1, R2
		MOVHI R8, R1
		MOVHI R1, R2
		MOVHI R2, R8

		CMP R0, R1
		MOVHI R8, R0
		MOVHI R0, R1
		MOVHI R1, R8

		;Computing 	R1/R0
		MOV R3, R1
LOOP1
		SUB R3, R3, R0
		ADD R6, #1
		CMP R0, R3
		BLS LOOP1 ;jump if R0 <= R3
		CMP R3, #0
		BNE Continue1 ;jump if R3 != 0
		MOV R4, R6	;I'm here if R1 is multiplier of R0

Continue1
		;Computing R2/R0
		MOV R3, R2
LOOP2
		SUB R3, R3, R0
		ADD R7, #1
		CMP R0, R3
		BLS LOOP2
		CMP R3, #0
		BNE Continue2
		MOV R5, R7	  ;I'm here if R2 is multiplier of R0
Continue2
	   ;Clean temp registers
	   EOR R6, R6
	   EOR R7, R7
	   EOR R8, R8
	B reset_handler
		END