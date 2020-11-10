	.syntax unified
	.cpu cortex-m4
	.thumb
.data
	leds: .byte 0
.text
	.global main
	.equ RCC_AHB2ENR, 0x4002104C
	.equ GPIOB_MODER, 0x48000400
	.equ GPIOB_OTYPER, 0x48000404
	.equ GPIOB_OSPEEDR, 0x48000408
	.equ GPIOB_PUPDR, 0x4800040C
	.equ GPIOB_ODR, 0x48000414
main:
	BL GPIO_init
	//MOVS R9, #0b11110011 //R9 -> which led have to be turned on
	MOVS R9, #0b1100 //active high
	MOVS R8, #0 //R8 -> index of moveleft or moveright
	MOVS R1, #0 //R1 -> index


Loop:
	/* TODO: Write the display pattern into leds variable */
	ADDS R1, R1, #1
	LDRB R0, =leds //R0 -> record the num of moving
	STRB R1, [R0]
	BL DisplayLED
	BL Delay
	BL Modify
	ADDS R8, R8, #1
	B Loop
GPIO_init:
	/* TODO: Initialize LED GPIO pins as output */
	// Enable AHB2 clock
	MOVS R0, #0b10
	LDR R1, = RCC_AHB2ENR
	LDR R2, [R1]
	AND R2, #0xFFFFFFFD
	ORR R2, R2, R0
	STR R2, [R1]
	// Set pins (Ex. PB3-6) as output mode
	MOVS R0, #0b01010101000000
	LDR R1, = GPIOB_MODER
	LDR R2, [R1]
	AND R2, #0xFFFFC03F
	ORR R2, R2, R0
	STR R2, [R1]
	// Keep PUPDR as the default value(pull-up). =>defalut->do nothing
	// Set output speed register
	MOVS R0, #0b10101010000000
	LDR  R1, =GPIOB_OSPEEDR
	STRH R0, [R1]
	//set output
	LDR R10, = GPIOB_ODR //R10 -> output reg
	BX LR
DisplayLED:
	/* TODO: Display LED by leds */
	STRH R9, [R10]
	BX LR
Delay:
	/* TODO: Write a delay 1 sec function */
	LDR R4, =0x7FF
L1:	LDR R5, =0xFF
L2:	SUBS R5, #1
	BNE L2
	SUBS R4, #1
	BNE L1
	BX LR
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
	//ADDS R9, R9, #1
	BX LR
MoveRight:
	MOVS R9, R9, LSR #1
	BX LR
