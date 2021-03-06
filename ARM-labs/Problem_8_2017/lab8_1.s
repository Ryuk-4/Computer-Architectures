;/*****************************************************************************/
;/* STARTUP.S: Startup file for Philips LPC2000                               */
;/*****************************************************************************/
;/* <<< Use Configuration Wizard in Context Menu >>>                          */
;/*****************************************************************************/
;/* This file is part of the uVision/ARM development tools.                   */
;/* Copyright (c) 2005-2007 Keil Software. All rights reserved.               */
;/* This software may only be used under the terms of a valid, current,       */
;/* end user licence from KEIL for a compatible version of KEIL software      */
;/* development tools. Nothing else gives you the right to use this software. */
;/*****************************************************************************/


; Standard definitions of Mode bits and Interrupt (I & F) flags in PSRs

Mode_USR        EQU     0x10
Mode_FIQ        EQU     0x11
Mode_IRQ        EQU     0x12
Mode_SVC        EQU     0x13
Mode_ABT        EQU     0x17
Mode_UND        EQU     0x1B
Mode_SYS        EQU     0x1F

I_Bit           EQU     0x80            ; when I bit is set, IRQ is disabled
F_Bit           EQU     0x40            ; when F bit is set, FIQ is disabled


;// <h> Stack Configuration (Stack Sizes in Bytes)
;//   <o0> Undefined Mode      <0x0-0xFFFFFFFF:8>
;//   <o1> Supervisor Mode     <0x0-0xFFFFFFFF:8>
;//   <o2> Abort Mode          <0x0-0xFFFFFFFF:8>
;//   <o3> Fast Interrupt Mode <0x0-0xFFFFFFFF:8>
;//   <o4> Interrupt Mode      <0x0-0xFFFFFFFF:8>
;//   <o5> User/System Mode    <0x0-0xFFFFFFFF:8>
;// </h>

UND_Stack_Size  EQU     0x00000080
SVC_Stack_Size  EQU     0x00000080
ABT_Stack_Size  EQU     0x00000000
FIQ_Stack_Size  EQU     0x00000000
IRQ_Stack_Size  EQU     0x00000080
USR_Stack_Size  EQU     0x00000400

ISR_Stack_Size  EQU     (UND_Stack_Size + SVC_Stack_Size + ABT_Stack_Size + \
                         FIQ_Stack_Size + IRQ_Stack_Size)

                AREA    STACK, NOINIT, READWRITE, ALIGN=3

Stack_Mem       SPACE   USR_Stack_Size
__initial_sp    SPACE   ISR_Stack_Size

Stack_Top


;// <h> Heap Configuration
;//   <o>  Heap Size (in Bytes) <0x0-0xFFFFFFFF>
;// </h>

Heap_Size       EQU     0x00000100

                AREA    HEAP, NOINIT, READWRITE, ALIGN=3

Heap_Mem        SPACE   Heap_Size
result  SPACE 0x00000120



                PRESERVE8


; Area Definition and Entry Point
;  Startup Code must be linked first at Address at which it expects to run.

                AREA    RESET, CODE, READONLY
                ARM


; Exception vector table handles every type of exceptions.
;  It is mapped to Address 0.
;  Absolute addressing mode must be used.
;  Dummy Handlers are implemented as infinite loops which can be modified.

Vectors         LDR     PC, Reset_Addr			; reset
                LDR     PC, Undef_Addr			; undefined instruction
                LDR     PC, SWI_Addr			; software interrupt
                LDR     PC, PAbt_Addr			; prefetch abort
                LDR     PC, DAbt_Addr			; data abort
                NOP                             ; reserved vector
                LDR     PC, IRQ_Addr			; IRQ
                LDR     PC, FIQ_Addr			; FIQ

Reset_Addr      DCD     Reset_Handler
Undef_Addr      DCD     Undef_Handler
SWI_Addr        DCD     SWI_Handler
PAbt_Addr       DCD     PAbt_Handler
DAbt_Addr       DCD     DAbt_Handler
                DCD     0                      ; Reserved Address
IRQ_Addr        DCD     IRQ_Handler
FIQ_Addr        DCD     FIQ_Handler

Undef_Handler   B       Undef_Handler
PAbt_Handler    B       PAbt_Handler
DAbt_Handler    B       DAbt_Handler
IRQ_Handler     B       IRQ_Handler
FIQ_Handler     B       FIQ_Handler

;SWI management
SWI_Handler
				STMFD 	sp!, {r0-r5, r7-r12, lr} ;Store registers in the stack and store the link register
        		;r6 will contain the result if there will be OVERFLOW
				LDR r0, [lr, #-4] ;lr is pointing to the next instruction after the swi
				BIC 	r1, r0, #0xff000000  ;BIC dest, op1, op2 -> dest = op1 AND !(op2)
				; test the identification code of the interrupt
				CMP 	r1, #0x10
        		BNE secondCode

        		MOV R6, #0x7FFFFFFF
        		B end_swi

secondCode
        		CMP R1, #0x20
        		BNE 	end_swi
       			MOV R6, #0x80000000

end_swi			LDMFD 	sp!, {r0-r5, r7-r12, pc}^ ;Restore the registers and put LR into PC so the Program
                                       ;can continue.


; Reset Handler
Reset_Handler


; Initialise Interrupt System
;  ...


; Setup Stack for each mode

                LDR     R0, =Stack_Top

;  Enter Undefined Instruction Mode and set its Stack Pointer
; MSR transfers the value of the immediate to the Program Status Register (CPSR).
; CPSR indicates the state of the machine: it contains condition code flags,
; interrupt enable flags, the current mode, and the current state.
; We change the mode by updating CPSR

                MSR     CPSR_c, #Mode_UND:OR:I_Bit:OR:F_Bit
                MOV     SP, R0
                SUB     R0, R0, #UND_Stack_Size

;  Enter Abort Mode and set its Stack Pointer
                MSR     CPSR_c, #Mode_ABT:OR:I_Bit:OR:F_Bit
                MOV     SP, R0
                SUB     R0, R0, #ABT_Stack_Size

;  Enter FIQ Mode and set its Stack Pointer
                MSR     CPSR_c, #Mode_FIQ:OR:I_Bit:OR:F_Bit
                MOV     SP, R0
                SUB     R0, R0, #FIQ_Stack_Size

;  Enter IRQ Mode and set its Stack Pointer
                MSR     CPSR_c, #Mode_IRQ:OR:I_Bit:OR:F_Bit
                MOV     SP, R0
                SUB     R0, R0, #IRQ_Stack_Size

;  Enter Supervisor Mode and set its Stack Pointer
                MSR     CPSR_c, #Mode_SVC:OR:I_Bit:OR:F_Bit
                MOV     SP, R0
                SUB     R0, R0, #SVC_Stack_Size

;  Enter User Mode and set its Stack Pointer
                MSR     CPSR_c, #Mode_USR
                MOV     SP, R0
                SUB     SL, SP, #USR_Stack_Size



; main program starts here.
; The interrupt service routine with identification code 10h is called

literal1 DCD 0x10, 0x70000000, 0xFFFFFFE0, 0x800000F0, 0x100EC023
literal2 DCD 0x200, 0x12345678, 0xE00A1238, 0xF0004538, 0xE9800348
N EQU 5
		  ;R0 <- addr of the result
		  ;R1 <- iteration counter
		  ;R2 <- index of literal1
		  ;R3 <- index of literal2
		  ;R4 <- i-th value of literal1
		  ;R5 <- i-th value of literal2
		  ;R6 <- result of the interrupt
		  ;R7 <- sign of operand1
		  ;R8 <- sign of operand2
		  ;R9 <- sum of R4 & R5
		  ;R10 <- sign of the sum
          LDR R0, =result 
		  
		  MOV R1, #0 ; counter = 0
		  
		  LDR R2, =literal1
		  LDR R3, =literal2
		  
cycle
		  LDR R4, [R2]
		  LDR R5, [R3]
		  
		  BIC R7, R4, #0x7FFFFFFF ;R7 = R4 AND 0x80000000
		  CMP R7, #0x80000000
		  BEQ OP1_Neg
		  BIC R8, R5, #0x7FFFFFFF ;R8 = R5 AND 0x80000000
		  CMP R8, #0x80000000
		  BEQ OP2_Neg

bothPositive
		  ADD R9, R4, R5
		  BIC R10, R9, #0x7FFFFFFF
		  CMP R10, #0x80000000	  
		  BNE No_Overflow			
		  SWI #0x10
		  B Overflow

OP1_Neg
		  BIC R8, R5, #0x7FFFFFFF ;R8 = R5 AND 0x80000000
		  CMP R8, #0x80000000
		  BEQ bothNegative
OP2_Neg
		  ADD R9, R4, R5
		  B No_Overflow

bothNegative
		  ADD R9, R4, R5
		  BIC R10, R9, #0x7FFFFFFF
		  CMP R10, #0
		  BNE No_Overflow
		  SWI #0x20
		  B Overflow
No_Overflow
		  STR R9, [R0], #4
		  B nextIteration
Overflow
		  STR R6, [R0], #4
nextIteration
		  ADD R1, R1, #1
		  ADD R2, R2, #4
		  ADD R3, R3, #4		  
		  CMP R1, #N
		  BEQ Reset_Handler 
		  B cycle


                END