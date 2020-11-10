	.syntax unified
	.cpu cortex-m4
	.thumb
.data
	//TODO: put your student id here
	student_id: .byte 0,7,1,6,0,8,8
.text
	.global main
	.equ RCC_AHB2ENR, 0x4002104C
	.equ GPIOA_MODER, 0x48000000
	.equ GPIOA_OTYPER, 0x48000004
	.equ GPIOA_OSPEEDR, 0x48000008
	.equ GPIOA_PUPDR, 0x4800000C
	.equ GPIOA_ODR, 0x48000010

	.equ DATA,0x20//PA5
	.equ LOAD,0x40//PA6
	.equ CLOCK,0x80//PA7
	.equ DECODE_MODE, 0x9
	.equ INTENSITY,   0xA
	.equ SCAN_LIM,    0xB
	.equ DISPLAYTEST, 0xF
	.equ SHUTDOWN,    0xC

	.equ GPIOA_BASE, 0x48000000
	.equ GPIO_BSRR_OFFSET, 0x18 //set bit
	.equ GPIO_BRR_OFFSET, 0x28 //clear bit
main:
	BL GPIO_init
	BL max7219_init
	//TODO: display your student id on 7-Seg LED
	BL DISPLAY_ID
Program_end:
	B Program_end

DISPLAY_ID:
	push {r0,r1,lr}

	ldr r8,=student_id
	ldr r9,=0 //ptr of sturdent id
	ldr r0,=7 //ptr of led position
display_loop:
	ldrb r1,[r8,r9]
	bl MAX7219Send
	ldr r4,=1
	sub r0,r0,r4
	add r9,r9,r4
	cmp r0,#0
	beq enddisplay
	b display_loop
enddisplay:
	pop {r0,r1,pc}

GPIO_init:
	//TODO: Initialize three GPIO pins as output for max7219 DIN, CS and CLK
	// Enable AHB2 clock
	ldr r0,=1
	ldr r1,=RCC_AHB2ENR
	str r0,[r1]

	// Set pins (PA5-7) as output mode
	ldr r1,=GPIOA_MODER
	ldr r2,[r1]
	and r2,#0xffff57ff
	str r2,[r1]

	// Keep PUPDR as the default value(pull-up).
	movs r0,#0b0101010000000000
	ldr r1,=GPIOA_PUPDR
	str r0,[r1]

	// Set output speed register as high speed
	movs r0,#0b1010100000000000 //101010000000
	ldr r1,=GPIOA_OSPEEDR
	str r0,[r1]

	BX LR

MAX7219Send:
	//input parameter: r0 is ADDRESS , r1 is DATA
	//TODO: Use this function to send a message to max7219
	//{pA5,pA6,pA7}={DIN,CS,CLK}
	push {r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,lr}
	lsl r0, r0, #8
	add r0, r0, r1
	ldr r1, =#GPIOA_BASE
	ldr r2, =#LOAD
	ldr r3, =#DATA
	ldr r4, =#CLOCK
	ldr r5, =#GPIO_BSRR_OFFSET
	ldr r6, =#GPIO_BRR_OFFSET
	mov r7, #16//r7 = i
max7219send_loop:
	mov r8, #1
	sub r9, r7, #1
	lsl r8, r8, r9 // r8 = mask
	str r4, [r1,r6]//HAL_GPIO_WritePin(GPIOA, CLOCK, 0);
	tst r0, r8
	beq bit_not_set//bit not set
	str	r3, [r1,r5]
	b if_done
bit_not_set:
	str r3, [r1,r6]
if_done:
	str r4, [r1,r5]
	subs r7, r7, #1
	bgt max7219send_loop
	str r2, [r1,r6]
	str r2, [r1,r5]
	pop {r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,pc}
max7219_init:
	//TODO: Initial max7219 registers.
	//{pA5,pA6,pA7}={DIN,CS,CLK}

	push {r0,r1,lr}

	//set decode mode
	ldr r0,=DECODE_MODE
	ldr r1,=0b11111111 //live coding
	//ldr r1,=0b01111111
	bl MAX7219Send

	//set display test
	ldr r0,=DISPLAYTEST
	ldr r1,=0
	bl MAX7219Send

	//set intensity
	ldr r0,=INTENSITY
	ldr r1,=0x0f
	bl MAX7219Send

	//set scan limit
	ldr r0,=SCAN_LIM
	ldr r1,=0b111
	bl MAX7219Send

	//set shutdown reg
	ldr r0,=SHUTDOWN
	ldr r1,=1
	bl MAX7219Send

	ldr r0, =1 //live coding
	ldr r1, =0xF //live coding
	bl MAX7219Send //live coding
	ldr r0, =2 //live coding
	ldr r1, =0xF //live coding
	bl MAX7219Send //live coding
	ldr r0, =3 //live coding
	ldr r1, =0xF //live coding
	bl MAX7219Send //live coding
	ldr r0, =4 //live coding
	ldr r1, =0xF //live coding
	bl MAX7219Send //live coding
	ldr r0, =5 //live coding
	ldr r1, =0xF //live coding
	bl MAX7219Send //live coding
	ldr r0, =6 //live coding
	ldr r1, =0xF //live coding
	bl MAX7219Send //live coding
	ldr r0, =7 //live coding
	ldr r1, =0xF //live coding
	bl MAX7219Send //live coding
	ldr r0, =8 //live coding
	ldr r1, =0xF //live coding
	bl MAX7219Send //live coding

	pop {r0,r1,pc}
