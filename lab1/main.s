	.syntax unified
	.cpu cortex-m4
	.thumb

.data
	arr1: .byte 0x19, 0x34, 0x14, 0x32, 0x52, 0x23, 0x61, 0x29
	arr2: .byte 0x18, 0x17, 0x33, 0x16, 0xFA, 0x20, 0x55, 0xAC
	len: .byte 0x08
.text
	.global main
do_sort:
	mov R2, #0 //R2->iterater of outer loop
	str lr, [sp,#-4]!

outer_loop:
	sub R4, R1, #1 //the condition of outer loop iterater < len-1
	cmp R2, R4
	bge outer_loop_end //>= len=1 -> end outer loop
	mov R3, #0 //R3->iterater of inner loop

inner_loop:
	sub R5, R4 ,R2 //the condition of inner loop iterater < len-1-i
	cmp R3, R5
	bge inner_loop_end //>= len-1-i -> end inner loop

	ldrb R5, [R0,R3] //get the first number
	add R7, R3 ,#1
	ldrb R6, [R0,R7] //get the second number
	cmp R5, R6
	blt swap
	add R3, R3, #1
	b inner_loop

inner_loop_end:
	add R2, R2, #1
	b outer_loop

outer_loop_end:
	 ldr pc, [sp], #4

swap:
	strb R5, [R0,R7]
	strb R6, [R0,R3]
	add R3, R3, #1
	b inner_loop

main:
	ldr R0, =arr1 //R0->arr
	ldr R2, =len
	ldr R1, [R2] //R1->number of num
	bl do_sort
	ldr R0, =arr2
	bl do_sort
L: b L
