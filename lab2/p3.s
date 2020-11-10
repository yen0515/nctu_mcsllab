	.syntax unified
	.cpu cortex-m4
	.thumb
.data
	result: .word 0
	max_size: .word 0
.text
	m: .word 0x4E
	n: .word 0x82

.global main
main:
	ldr R2, =m //address of R2 = m
	ldr R0, [R2]
	ldr R3, =n //address of R3 = n
	ldr R1, [R3]
	mov R6, sp //R6->stack start
	movs R5, #0x0 //R5->max stack size
	mov R12, #1
	push {R0,R1,lr}
	bl gcd

	ldr R4, =result
	str R2, [R4]
	ldr R4, =max_size
	mov R3, R5, lsr #3
	str R3, [R4]
	b L
L: b L
gcd:
	ldr R0, [sp] //a
	ldr R1, [sp, #4] //b
	mov R4, sp
	sub R7, R6, R4
	cmp R7, R5 //check max stack size
	bgt update_siz
	b gcd_deci
update_siz:
	mov R5, R7
gcd_deci:
	cmp R0, #0
	beq return_b //if(a==0) return b
	cmp R1, #0
	beq return_a //if(b==0) return a
	mov R7, #0x1
	and R2, R0, R7 //R2->check if a even
	and R3, R1, R7 //R3->check if b even
	eor R4, R2, #1 //R4->check if a and b both even
	eor R7, R3, #1
	and R4, R4, R7
	cmp R4, #1
	beq both_even
	cmp R2, #0
	beq a_even
	cmp R3, #0
	beq b_even
	b both_odd
return_a:
	mov R2, R0
	bx lr
return_b:
	mov R2, R1
	bx lr
both_even:
	asr R0, R0, 0x1
	asr R1, R1, 0x1
	push {R0, R1, lr}
	bl gcd
	pop {R0, R1, R9} //R9->tem lr
	mov R7, #2
	mul R2, R2, R7
	add R12, R12, #1
	bx R9
a_even:
	mov R0, R0, lsr #1
	push {R0, R1, lr}
	bl gcd
	pop {R0, R1, R9} //R9->tem lr
	add R12, R12, #1
	bx R9
b_even:
	mov R1, R1, lsr #1
	push {R0, R1, lr}
	bl gcd
	pop {R0, R1, R9} //R9->tem lr
	add R12, R12, #1
	bx R9
both_odd:
	cmp R0, R1
	bgt R0_larg
	b R1_larg
R0_larg:
	sub R7, R0, R1 //R7->abs(a-b)
	mov R11, R1 //R11->min(a,b)
	mov R0, R7
	mov R1, R11
	push {R0, R1, lr}
	bl gcd
	pop {R0, R1, R9}
	add R12, R12, #1
	bx R9
R1_larg:
	sub R7, R1, R0 //R7->abs(a-b)
	mov R11, R0
	mov R0, R7
	mov R1, R11
	push {R0, R1, lr}
	bl gcd
	pop {R0, R1, R9}
	add R12, R12, #1
	bx R9
