	.syntax unified
	.cpu cortex-m4
	.thumb
.data
	infix_expr: .asciz "{-99+ [ 10 + 20-0] }"
	user_stack_bottom: .zero 128
.text
	.global main
	//move infix_expr here. Please refer to the question below.

main:
	bl stack_init
	ldr R0, =infix_expr
	bl pare_check
L: 	b L
stack_init:
	ldr R1, =(user_stack_bottom+128) //R1->top of the stack
	msr MSP, R1
	bx LR
pare_check:
	//TODO: check parentheses balance, and set the error code to R0.
	push {lr}
	mov R3, #0
	push {R3} //endmarker
	sub R0, R0, #4
	mov R8, #0 //midd yes flag
	mov R9, #0 // larg yes flag
	mov R10, #0 //both yes flag
	mov R11, #0 //midd no flag
	mov R12, #0 //larg no flag
	mov R7, #0 //index
	bl decidenum
	pop {lr}
	bx LR
decidenum:
	ldr R2, [R0, #4]!
	add R7, R7, #1
	cmp R7, #6
	beq right
	cmp R10, #1
	beq checkbar
	cmp R8, #1
	beq checkbar_larg1
	cmp R9, #1
	beq checkbar_midd1
	cmp R11, #1
	beq checkbar_larg2
	cmp R12, #1
	beq checkbar_midd2
	b uncheckbar
uncheckbar:
	and R3, R2, #0x7B //check rightmost 8 bits
	cmp R3, #0x7B
	beq largpar_1
	and R3, R2, #0x7D
	cmp R3, #0x7D
	beq wrong
	and R4, R2, #0x5B
	cmp R4, #0x5B
	beq middpar_1
	and R4, R2, #0x5D
	cmp R4, #0x5D
	beq wrong
	movs R2, R2, lsr #8
	cmp R2, #0
	beq decidenum
	b uncheckbar
middpar_1:
	movs R9, #1
	mov R3, #0x5B
	push {R3}
	movs R2, R2, lsr #8
	cmp R2, #0
	beq decidenum
	b checkbar_midd1
largpar_1:
	mov R8, #1
	mov R4, #0x7B
	push {R4}
	movs R2, R2, lsr #8
	cmp R2, #0
	beq decidenum
	b checkbar_larg1
checkbar_midd1:
	and R3, R2, #0x7B //check rightmost 8 bits
	cmp R3, #0x7B
	beq largpar_2
	and R3, R2, #0x7D
	cmp R3, #0x7D
	beq wrong
	and R4, R2, #0x5B
	cmp R4, #0x5B
	beq wrong
	and R4, R2, #0x5D
	cmp R4, #0x5D
	beq middpar_4
	movs R2, R2, lsr #8
	cmp R2, #0
	beq decidenum
	b checkbar_midd1
checkbar_larg1:
	and R3, R2, #0x7B //check rightmost 8 bits
	cmp R3, #0x7B
	beq wrong
	and R3, R2, #0x7D //check rightmost 8 bits
	cmp R3, #0x7D
	beq largpar_4
	and R4, R2, #0x5B
	cmp R4, #0x5B
	beq middpar_2
	and R4, R2, #0x5D
	cmp R4, #0x5D
	beq wrong
	movs R2, R2, lsr #8
	cmp R2, #0
	beq decidenum
	b checkbar_larg1
middpar_2:
	mov R8, #0
	mov R10, #1
	mov R3, #0x5B
	push {R3}
	movs R2, R2, lsr #8
	cmp R2, #0
	beq decidenum
	b checkbar
largpar_2:
	mov R9, #0
	mov R10, #1
	mov R4, #0x7B
	push {R4}
	movs R2, R2, lsr #8
	cmp R2, #0
	beq decidenum
	b checkbar
checkbar:
	and R3, R2, #0x7B //check rightmost 8 bits
	cmp R3, #0x7B
	beq largpar_1
	and R3, R2, #0x7D //check rightmost 8 bits
	cmp R3, #0x7D
	beq largpar_3
	and R4, R2, #0x5B
	cmp R4, #0x5B
	beq middpar_1
	and R4, R2, #0x5D
	cmp R4, #0x5D
	beq middpar_3
	movs R2, R2, lsr #8
	cmp R2, #0
	beq decidenum
	b checkbar
middpar_3:
	mov R10, #0
	mov R11, #1
	pop {R3}
	cmp R3, #0x5B
	bne wrong
	cmp R3, #0 //meet endmarker
	beq wrong
	movs R2, R2, lsr #8
	cmp R2, #0
	beq decidenum
	b checkbar_larg2
largpar_3:
	mov R10, #0
	mov R12, #1
	pop {R4}
	cmp R4, #0x7B
	bne wrong
	cmp R4, #0
	beq wrong //meet endmarker
	movs R2, R2, lsr #8
	cmp R2, #0
	beq decidenum
	b checkbar_midd2
checkbar_larg2:
	and R3, R2, #0x7B //check rightmost 8 bits
	cmp R3, #0x7B
	beq largpar_1
	and R3, R2, #0x7D //check rightmost 8 bits
	cmp R3, #0x7D
	beq largpar_4
	and R4, R2, #0x5B
	cmp R4, #0x5B
	beq middpar_1
	and R4, R2, #0x5D
	cmp R4, #0x5D
	beq middpar_3
	movs R2, R2, lsr #8
	cmp R2, #0
	beq decidenum
	b checkbar_larg2
checkbar_midd2:
	and R3, R2, #0x7B //check rightmost 8 bits
	cmp R3, #0x7B
	beq largpar_1
	and R3, R2, #0x7D //check rightmost 8 bits
	cmp R3, #0x7D
	beq largpar_3
	and R4, R2, #0x5B
	cmp R4, #0x5B
	beq middpar_1
	and R4, R2, #0x5D
	cmp R4, #0x5D
	beq middpar_4
	movs R2, R2, lsr #8
	cmp R2, #0
	beq decidenum
	b checkbar_midd2
largpar_4:
	mov R11, #0
	pop {R4}
	cmp R4, #0x7B
	bne wrong
	cmp R4, #0
	beq wrong //meet endmarker
	movs R2, R2, lsr #8
	cmp R2, #0
	beq decidenum
	b uncheckbar
middpar_4:
	mov R12, #0
	pop {R3}
	cmp R3, #0x5B
	bne wrong
	cmp R4, #0
	beq wrong //meet endmarker
	movs R2, R2, lsr #8
	cmp R2, #0
	beq decidenum
	b uncheckbar
wrong:
	mov R0, #-1
	b clear
right:
	mov R0, #0
	pop {R3} //pop endmarker
	bx lr //return to pare_check
clear:
	pop {R3}
	cmp R3, #0
	bne clear
	bx lr //return to pare_check


