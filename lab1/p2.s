	.syntax unified
	.cpu cortex-m4
	.thumb

.text
		.global main
	.equ N, 49
fib:
	cmp R0, #100 //N=V=0 -> >100
	bgt Nrange
	cmp R0, #0 //Z=1 -> <0
	blt Nrange //upper is the solution to the condition N is out of range

	cmp R1, #0
	beq zero
	cmp R1, #1
	beq one
	movs R2, R4 //R2 temporary store last answer
	add R4, R4, R3
	eor R5, R4, R3 //check if overflow
	cmp R5, #0
	blt overflow
	movs R3, R2
	add R1, R1, #1
	cmp R1, R0 //if the index < (N+1)
	blt fib
	bx lr
main:
	movs R0, #N
	movs R1, #0 //R1 is the index
	bl fib
L: b L
zero:
	movs R3, #0 //R3 is the last answer
	movs R4, #0 //R4 is the answer
	add R1, R1, #1
	add R0, R0, #1 //modify the maximum
	cmp R1, R0 //if the index < (N+1)
	blt fib
	bx lr
one:
	movs R3, #0
	movs R4, #1
	add R1, R1, #1
	cmp R1, R0 //if the index < (N+1)
	blt fib
	bx lr
Nrange:
	movs R4, #-1 //set R4 to -1
	bx lr //return to main
overflow:
	movs R4, #-2
	bx lr
