	AREA myCode, CODE, READONLY
		  
reset_handler
		ENTRY

		LDR R0, =1
		LDR R1, =2
		LDR R2, =3
		LDR R3, =3
		LDR R4, =5
		LDR R5, =6
		LDR R6, =7
		LDR R7, =8

		CMP R0,R1
		;R8 = R0 + R1 if R0 != R1
		ADDNE R8, R0, R1
		;if R0 != R1, then divide it by 2
		LSRNE R8, R8, #1 ; -> right shift if not equal
		;if R0 = R1, then multiply them
		MULEQ R8, R0, R1
;;
;;
;; Repeat the above's code for each couples of values
		CMP R2,R3
		ADDNE R9, R2, R3
		LSRNE R9, R9, #1
		MULEQ R9, R2, R3

		CMP R4,R5
		ADDNE R10, R4, R5
		LSRNE R10, R10, #1
		MULEQ R10, R4, R5

		CMP R6,R7
		ADDNE R11, R6, R7
		LSRNE R11, R11, #1
		MULEQ R11, R6, R7

		B reset_handler
		END