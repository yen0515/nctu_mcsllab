	.syntax unified
	.cpu cortex-m4
	.thumb
.data
	result: .zero 8
.text
	.global main
	.equ X, 0x12345678
	.equ Y, 0xabcdef00
main:
	ldr R0, =X
	ldr R1, =Y
	ldr R2, =result
	bl kara_mul
L:
	b L
kara_mul:
	//TODO: Separate the leftmost and rightmost halves into different registers; then do the Karatsuba algorithm.
	mov R3, R0, lsr #16 //R3->left part of X
	mov R4, R0, lsl #16 //R4->right part of X
	mov R5, R1, lsr #16 //R5->left part of Y
	mov R6, R1, lsl #16 //R6->right part of Y
	mov R4, R4, lsr #16
	mov R6, R6, lsr #16
	mul R7, R3, R5 //R7->XL*YL
	mul R8, R4, R6 //R8->XR*YR
	add R9, R3, R4
	add R10, R5, R6
	mul R9, R9, R10 //R9->(XL+XR)*(YL+YR)
	add R10, R7, R8
	sub R10, R9, R10 //R10->(XL+XR)*(YL+YR)-(XLYL+XRYR)
	mov R3, R7 //R3->left part of 2^n*XLYL
	mov R4, #0x0 //R4->right part of 2^n*XLYL
	mov R5, R10, lsr #16 //R5->left part of 2^(n/2)[(XL+XR)*(YL+YR)-(XLYL+XRYR)]
	mov R6, R10, lsl #16 //R6->right part of 2^(n/2)[(XL+XR)*(YL+YR)-(XLYL+XRYR)]
	adds R10, R4, R6 //sum of right part
	adc R9, R3, R5 //sum of left part
	adds R10, R10, R8 //sum of right part
	adc R9, R9, #0x0 //sum of left part
	strd R9, R10, [R2]
	bx lr
