	.syntax unified
	.cpu cortex-m4
	.thumb

.data
	leds: .byte 0
	password: .byte 0b1101
	.align

.text
	.global main
	.equ RCC_AHB2ENR, 0x4002104C
	.equ GPIOA_MODER, 0x48000000
	.equ GPIOA_OTYPER, 0x48000004
	.equ GPIOA_OSPEEDR, 0x48000008
	.equ GPIOA_PUPDR, 0x4800000C
	.equ GPIOA_ODR, 0x48000014
	.equ GPIOC_MODER, 0x48000800
	.equ GPIOC_PUPDR, 0x4800080C
	.equ GPIOC_IDR, 0x48000810

main:
	BL GPIO_init
	LDR R3, = password
	LDR R2, [R3] //R2->password
	MOV R11, #1 ///R11 R12->debouncing
	MOV R12, #2
	MOV R7, #0 //R7->if pressed
	B Loop

GPIO_init:
	LDR R0, = RCC_AHB2ENR
	MOV R1, #0b101
	STR R1, [R0]

	LDR R0, = GPIOA_MODER
	LDR R2, [R0]
	MOV R1, #0b010000000000
	AND R2, #0xFFFFF3FF
	ORRS R1, R2
	STR R1, [R0]

	LDR R0, = GPIOA_OSPEEDR
	MOVS R1, #0b100000000000
	STRH R1, [R0]

	LDR R0, = GPIOC_MODER
	LDR R2, [R0]
	LDR R1, =#0xF3FFFF00
	AND R2, R1
	STR R2, [R0]

	ldr  r1, =GPIOC_PUPDR
	ldr  r2, [r1]
	ldr  r3, =0xF3FFFF00
	and  r2, r3
	ldr  r0, =0x04000066
	orrs r2, r2, r0
	str  r2, [r1]

	LDR R0, = GPIOA_ODR //R0->output reg
	LDR R1, = GPIOC_IDR //R1->input reg button
	LDR R6, = GPIOC_IDR //R6->input reg switch
	BX LR

Loop:
	//B ReadSwitch
	LDR  R3, =3100000 //R3->Delay
	MOVS R3, R3
	BL Delay
	MOV R9, #0 //light times
	CMP R7, #1
	BEQ ReadSwitch
	B Loop

Delay:
	BEQ  delay_end
	LDR  R4, =0b11111111111111111
	ANDS R4, R3, R4
	BEQ  CheckPress
	SUBS R3, #8
	B Delay

CheckPress:
	LDRH R4, [R1] //R1->input reg
	LSR  R4, #13
	MOV  R5, #1
	AND  R4, R5
	CMP  R4, R11
	MOV  R11, R4
	BEQ  Press
	SUBS R3, #8
	B Delay

Press:
	SUBS R5, R11, R12
	CMP  R5, #1
	MOV  R12, R11
	BEQ  switch
	SUBS R3, #8
	B Delay

switch:
	EOR  R7, #0b1
	SUBS R3, #8
	B Delay

delay_end:
	BX LR

ReadSwitch:
	LDRH R8, [R6]
	MOV R5, #0b1111
	AND R8, R5
	//EOR R8, #0xF
	CMP R8, R2
	BEQ Light3
	B Light1

Delay2:
	LDR R4, =0x5FF
L1:	LDR R5, =0xFF
L2:	SUBS R5, #1
	BNE L2
	SUBS R4, #1
	BNE L1
	BX LR

Light1:
	MOVS R10, #(1<<5)
	STRH R10, [R0]
	BL Delay2
	MOVS R10, #0
	STRH R10, [R0]
	EOR R7, #0b1
	B Loop

Light3:
	MOVS R10, #(1<<5)
	STRH R10, [R0]
	BL Delay2
	MOVS R10, #0
	STRH R10, [R0]
	CMP R9, #2
	BEQ Light_end
	ADD R9, #1
	BL Delay2
	B Light3

Light_end:
	EOR R7, #0b1
	B Loop

