	.syntax unified
	.cpu cortex-m4
	.thumb

.data
	result: .byte 0
.text
.global main
	.equ X, 0x123400
	.equ Y, 0x567800
main:
	ldr R0, =X //replace movs to ldr due to the size limitation
	ldr R1, =Y
	ldr R2, =result
	bl hamm //set the value of R14(lr) to the return address
	str R3, [R2]
L: b L
hamm:
	eor R1, R1, R0 //take xor of X and Y
	ldr R3, =0 //R3->the answer
	mov R4, lr //R4->store the return address
	bl Loop
	mov lr, R4
	bx lr //jump to the retuen adderss
Loop:
	and R5, R1, #1
	cmp R5, #0 //if R5=0 Z=1
	bne count //Z=1->branch to count
	b notcount
count:
	add R3, R3, #1 //answer += 1
	mov R1, R1, LSR #1
	cmn R1, #0 //if R1!=0 Z=1
	bne Loop //Z=1->still loop
	bx lr //else leave loop
notcount:
	mov R1, R1, LSR #1
	cmn R1, #0 //if R1!=0 Z=1
	bne Loop //Z=1->still loop
	bx lr //else leave loop
