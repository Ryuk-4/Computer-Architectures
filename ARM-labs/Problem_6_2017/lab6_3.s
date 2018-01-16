		AREA myCode, READONLY, CODE
		ENTRY
	    LDR PC, =reset_handler
 

;costantValues DCD 1, 2, 3, 4, 5, 6, 7, 8 ;; increasing sequence
;costantValues DCD 80, 70, 60, 50, 40, 30, 20, 10  ;; decreasing sequence
costantValues DCD 1, 10, 2, 20, 3, 30, 4, 40		;; not monotonic sequence

reset_handler

	;LDR LR, =Main
	LDR R0, =costantValues
	
	EOR R5, R5 ;mean
	EOR R6, R6 ;largest absolute difference
	;R7 = MAX
	;R8 = min
	MOV R10, #1 ;counter
	

	MOV R4, #1 ;index
	LDR R1, [R0] ; R1 <- 1st elem of costantValues
	;R2 <- 2nd elem of costantValues
	LDR R2, [R0, R4, LSL #2] ;R0 <- R3 * 4
	CMP R1, R2
	BHI DECREASING ; jump if R1 > R2
	MOV R5, R1
	ADD R5, R5, R2
	
INCREASING
	ADD R4, #1
	LDR R3, [R0, R4, LSL #2] ; R3 <- next element
	CMP R2, R3	;I'm here iff R1 < R2
	BHI NOT_MONOTONIC ;jump if R2 > R3
	MOV R2, R3 ;next iteration I'll check previous value with the new one
	
	ADD R5, R5, R3 ; R5 <- R1 + R2 + R3
	ADD R10, #1 ;Next iteration
	CMP	R10, #7
	BNE INCREASING
	LSR R5, R5, #3 ;Division by 8
	B END_
DECREASING
	SUB R5, R1, R2	;I'm here iff R1 > R2
	CMP R5, R6	;R5 > R6
	MOVHI R6, R5
	MOV R1, R2
	ADD R4, #1
	LDR R2, [R0, R4, LSL #2] ; R2 <- next element
	CMP R1, R2
	BLS NOT_MONOTONIC ;jump if R1 <= R2
	ADD R10, #1
	CMP R10, #7
	BNE DECREASING
	B END_
NOT_MONOTONIC
	MOV R7, R1 ; MAX
	MOV R8, R1 ; min
	SUB R4, R4, #1; since it was incremented into previous label
CYCLE
	LDR R2, [R0, R4, LSL #2] ; R2 <- next element
	CMP R2, R7
	MOVHI R7, R2 
	CMP R2, R8
	MOVLS R8, R2
	ADD R4, #1	
	ADD R10, #1
	CMP R10, #8
	BNE	 CYCLE

END_
	B reset_handler
		END