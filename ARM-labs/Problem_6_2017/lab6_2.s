		AREA myCode, READONLY, CODE
		ENTRY

reset_handler

		LDR R0, =1
		LDR R1, =2
		LDR R2, =3
		LDR R3, =4
		LDR R4, =5
		LDR R5, =6
		LDR R6, =7
		LDR R7, =8

		CMP R0,R1
	;R8 = R0 + R1 if R0 != R1
		ADDNE R8, R0, R1
		LSRNE R8, R8, #1
		MULEQ R8, R0, R1

		LDR R0, =5
		LDR R1, =2
		LDR R2, =4

		CMP R0, R1
		MOVHI R4, R0
		MOVHI R0, R1
		MOVHI R1, R4

		CMP R1, R2
		MOVHI R4, R1
		MOVHI R1, R2
		MOVHI R2, R4





	B reset_handler
	END
