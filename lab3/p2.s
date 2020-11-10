	.syntax unified
	.cpu cortex-m4
	.thumb

.data
	leds: .byte 0
	.align

.text
	.global main
	.equ RCC_AHB2ENR, 0x4002104C
	.equ GPIOB_MODER, 0x48000400
	.equ GPIOB_OTYPER, 0x48000404
	.equ GPIOB_OSPEEDR, 0x48000408
	.equ GPIOB_PUPDR, 0x4800040C
	.equ GPIOB_ODR, 0x48000414
	.equ GPIOC_MODER, 0x48000800
	.equ GPIOC_IDR, 0x48000810


main:
	BL   GPIO_init
	MOV  R9, #0b11110011 //R9 -> which led have to be turned on
	MOV  R8, #0b0 //R8-> index of moveleft or moveright
	MOV  R7, #0b0 //R7->if stopped
	MOV  R11, #0b1
	MOV  R12, #0b1 //R11R12-> debouncing
	B    Loop

GPIO_init:
	// Enable AHB2 clock
	MOVS R0, #0b110
	LDR  R1, =RCC_AHB2ENR
	STR  R0, [R1]
	// Set pins (Ex. PB3-6) as output mode
	MOVS R0, #0b01010101000000
	LDR  R1, =GPIOB_MODER
	LDR  R2, [R1]
	AND  R2, #0xFFFFC03F
	ORRS R2, R0
	STR  R2, [R1]
	// set pc13 as input mode
	LDR  R1, =GPIOC_MODER
	LDR  R0, [R1]
	LDR  R2, =#0xF3FFFFFF
	AND  R0, R2
	STR  R0, [R1]
	// Keep PUPDR as the default value(pull-up). =>defalut->do nothing
	// Set output speed register
	MOVS R0, #0b10101010000000
	LDR  R1, =GPIOB_OSPEEDR
	STRH R0, [R1]
	//set input and output
	LDR  R10, =GPIOB_ODR
	LDR  R0, =GPIOC_IDR
	BX   LR

Loop:
	BL   Display_LED
	LDR  R5, =3100000
	MOVS R5, R5
	BL   Delay
	CMP  R7, #0b1
	BEQ  Loop
	BL Modify
	ADDS R8, R8, #1
	B Loop
Display_LED:
	EOR  R5, R9, #0xFFFFFFFF
	STRH R9, [R10] // R10 -> output data reg
	BX   LR
Modify:
	CMP R8, #8
	BGE TooLarge
	CMP R8, #3
	BGT MoveRight
	B MoveLeft
TooLarge:
	SUBS R8, R8, #8
	B Modify
MoveLeft:
	MOVS R9, R9, LSL #1
	ADDS R9, R9, #1
	BX LR
MoveRight:
	MOVS R9, R9, LSR #1
	BX LR
Delay:
	BEQ  delay_end
	LDR  R1, =0b11111111111111111
	ANDS R1, R5, R1
	BEQ  CheckPress
	SUBS R5, #8
	B Delay

CheckPress:
	LDRH R1, [R0] //R0->input reg
	LSR  R1, #13
	MOV  R2, #1
	AND  R1, R2
	CMP  R1, R11
	MOV  R11, R1
	BEQ  Press
	SUBS R5, #8
	B Delay

Press:
	SUBS R1, R11, R12
	CMP  R1, #1
	MOV  R12, R11
	BEQ  switch
	SUBS R5, #8
	B Delay

switch:
	EOR  R7, #0b1
	SUBS R5, #8
	B Delay

delay_end:
	BX LR
