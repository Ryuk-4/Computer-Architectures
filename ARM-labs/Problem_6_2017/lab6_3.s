		AREA myCode, READONLY, CODE
		ENTRY

reset_handler DCD Main

		costantValues DCD 1, 2, 3, 4, 5, 6, 7, 8 ;; increasing sequence
		;costantValues DCD 80, 70, 60, 50, 40, 30, 20, 10  ;; decreasing sequence
		;costantValues DCD 1, 10, 2, 20, 3, 30, 4, 40		;; not monotonic sequence

Main
	LDR LR, =Main
	LDR R0, =costantValues

	MOV R4, #1 ;index
	LDR R1, [R0] ; R1 <- 1st elem of costantValues
	;R2 <- 2nd elem of costantValues
	LDR R2, [R0, R4, LSL #2] ;R0 <- R3 * 4
	ADD R4, #1
	LDR R3, [R0, R4, LSL #2] ; R3 <- 3rd element
	CMP R1, R2
	BHI DECREASING ; jump if R1 > R2
INCREASING:
	CMP R2, R3	;I'm here iff R1 < R2
	BHI NOT_MONOTONIC ;jump if R2 > R3
	MOV R10, #3
	MOV R5, R1
	ADD R5, R5, R2
	ADD R5, R5, R3 ; R5 <- R1 + R2 + R3
	ADD R10, #1 ;Next iteration
	ADD R4, #1
	CMP

DECREASING:
	CMP R2, R3	;I'm here iff R1 > R2
	BLS NOT_MONOTONIC ;jump if R2 <= R3
NOT_MONOTONIC:

	CMP
	END_:
	B reset_handler
		END
