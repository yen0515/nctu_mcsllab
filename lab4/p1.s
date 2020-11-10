	.syntax unified
	.cpu cortex-m4
	.thumb
.data
	//TODO: put 0 to F 7-Seg LED pattern here
	arr: .byte 0b01111110, 0b00110000, 0b01101101, 0b01111001, 0b0110011, 0b01011011, 0b01011111, 0b01110000, 0b01111111, 0b01111011, 0b01110111, 0b00011111, 0b01001110, 0b00111101, 0b01001111, 0b01000111 //now coding
	//arr: .byte 0x0, 0x1, 0x2, 0x3, 0x4, 0x5, 0x6, 0x7, 0x8, 0x9, 0xA, 0xB, 0xC, 0xD, 0xE, 0xF
	//arr: .byte 0b00011100, 0b00011001, 0b0010101, 0b0001101, 0b00011100, 0b00011001, 0b0010101, 0b0001101 //live coding
.text
	.global main
	.equ RCC_AHB2ENR, 0x4002104C
	.equ GPIOA_MODER, 0x48000000
	.equ GPIOA_OTYPER, 0x48000004
	.equ GPIOA_OSPEEDR, 0x48000008
	.equ GPIOA_PUPDR, 0x4800000C
	.equ GPIOA_ODR, 0x48000014

	.equ DECODE_MODE, 0x09
	.equ INTENSITY, 0x0A
	.equ SCAN_LIMIT, 0x0B
	.equ SHUTDOWN, 0x0C
	.equ DISPLAY_TEST, 0x0F

	.equ DATA, 0x20 //PA5
	.equ LOAD, 0x40 //PA6
	.equ CLOCK, 0x80 //PA7

	.equ GPIOA_BASE, 0x48000000
	.equ GPIO_BSRR_OFFSET, 0x18 //set bit
	.equ GPIO_BRR_OFFSET, 0x28 //clear bit

main:
	BL GPIO_init
	BL max7219_init
	LDR R2, =arr
	MOV R3, 0 //index
	MOV R0, 0x1 //the first led
loop:
	BL DisplayDigit
	//ADD R0, 1 //live coding
	BL Delay
	ADD R3, 1
	CMP R3, 0x10 //now coding
	//CMP R0, 0x9 //live coding
	BNE loop
	//MOV R0, 1 //live coding
	MOV R3, 0
	B loop

GPIO_init:
	//TODO: Initialize GPIO pins(PA5~7) for max7219 DIN, CS and CLK
	LDR R0, =RCC_AHB2ENR
	MOV R1, 0b001
	STR R1, [R0]

	LDR R0, =GPIOA_MODER
	LDR R2, [R0]
	MOV R1, 0b0101010000000000
	AND R2, 0xFFFF03FF
	ORRS R1, R2
	STR R1, [R0]

	LDR R0, =GPIOA_OSPEEDR
	MOVS R1, 0b1010100000000000
	STR R1, [R0]

	BX LR

max7219_init:
	//TODO: Initialize max7219 registers
	push {R0, R1, R2, LR}
	LDR R0, =DECODE_MODE
	LDR R1, =0x0
	BL MAX7219Send
	LDR R0, =INTENSITY
	LDR R1, =0xA
	BL MAX7219Send
	LDR R0, =SCAN_LIMIT
	LDR R1, =0x0 //now coding
	//LDR R1, =0x7 //live coding
	BL MAX7219Send
	LDR R0, =SHUTDOWN
	LDR R1, =0x1
	BL MAX7219Send
	LDR R0, =DISPLAY_TEST
	LDR R1, =0x0
	BL MAX7219Send
	LDR R0, =1
	LDR R1, =0
	BL MAX7219Send
	LDR R0, =2
	LDR R1, =0
	BL MAX7219Send
	LDR R0, =3
	LDR R1, =0
	BL MAX7219Send
	LDR R0, =4
	LDR R1, =0
	BL MAX7219Send
	LDR R0, =5
	LDR R1, =0
	BL MAX7219Send
	LDR R0, =6
	LDR R1, =0
	BL MAX7219Send
	LDR R0, =7
	LDR R1, =0
	BL MAX7219Send
	LDR R0, =8
	LDR R1, =0
	BL MAX7219Send
	pop {R0, R1, R2, LR}
	BX LR

MAX7219Send:
	//input parameter: r0 is ADDRESS , r1 is DATA
	//TODO: Use this function to send a message to max7219
	push {R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, LR}
	LSL R0, R0, 8
	ADD R0, R0, R1
	LDR R1, =GPIOA_BASE
	LDR R2, =LOAD
	LDR R3, =DATA
	LDR R4, =CLOCK
	LDR R5, =GPIO_BSRR_OFFSET
	LDR R6, =GPIO_BRR_OFFSET
	MOV R7, 0x0F //index

MAX7219Send_Loop:
	MOV R8, 0x1
	SUB R9, R7, 1
	LSL R8, R8, R9
	STR R4, [R1,R6] //clk->0
	TST R0, R8 //check if the most left bit 1
	BEQ Not_Set
	STR R3, [R1,R5] //data->1
	B Done

Not_Set:
	STR R3, [R1,R6] //data->0

Done:
	STR R4, [R1,R5] //clk->1
	SUBS R7, 1
	BGT MAX7219Send_Loop
	STR R2, [R1,R6] //load->0
	STR R2, [R1,R5] //load->1
	pop {R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, PC}

DisplayDigit:
	//TODO: Display 0 to F at first digit on 7-SEG LED.
	MOV R10, LR
	LDRB R1, [R2, R3]
	BL MAX7219Send
	//CMP R0, 1 //live coding
	//BNE Unlighted //live coding
	//MOV R4, R0 //live coding
	//MOV R0, 8 //live coding
	//MOV R1, 0 //live coding
	//BL MAX7219Send //live coding
	//MOV R0, R4 //live coding
	MOV LR, R10
	BX LR

Unlighted:
	MOV R4, R0
	SUB R0, 1
	MOV R1, 0
	BL MAX7219Send
	MOV R0, R4
	MOV LR, R10
	BX LR

Delay:
	//TODO: Write a delay 1sec function
	LDR R4, =0x8FF
L1:	LDR R5, =0xFF
L2:	SUBS R5, #1
	BNE L2
	SUBS R4, #1
	BNE L1
	BX LR
