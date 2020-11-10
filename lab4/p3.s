	.syntax unified
	.cpu cortex-m4
	.thumb
.data
	fib_seq: .zero 40
.text
	.global main
	.equ RCC_AHB2ENR, 0x4002104C
	.equ GPIOA_MODER, 0x48000000
	.equ GPIOA_OTYPER, 0x48000004
	.equ GPIOA_OSPEEDR, 0x48000008
	.equ GPIOA_PUPDR, 0x4800000C
	.equ GPIOA_ODR, 0x48000010
	.equ GPIOC_MODER, 0x48000800
	.equ GPIOC_OSPEEDR,0x48000808
	.equ GPIOC_PUPDR, 0x4800080C
	.equ GPIOC_IDR,	  0x48000810

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
//
main:
	BL GPIO_init
	BL max7219_init
	BL fib_cal
	ldr r10,=0 //4*n
	ldr r12,=0 //1 if overflow
main_loop:
	bl display
	ldr r9,=0
	bl CheckPress
	cmp r9,#0
	beq main_loop //not press
	cmp r12,#0
	bne main_loop
	adds r10,#4
	B main_loop

display:
	push {lr}
	ldr r0,=fib_seq
	ldr r11,[r0,r10] // nth fib_seq
	// display r1 to max7219
	ldr r2,=0 // # of bits
	movs r3,r11
	ldr r4,=10 // base
	ldr r5,=1
cmp_loop:
	adds r2,r2,r5
	sdiv r3,r3,r4
	cmp r3,#0
	beq end_cmp
	b cmp_loop
end_cmp:
	//set scan limit
	cmp r2,#8
	ble xd
	ldr r11,=99999999
	ldr r2,=8
	ldr r12,=1 //overflow->no need to increase index of fib_seq
xd:
	//set scan limit
	ldr r0,=SCAN_LIM
	movs r1,r2
	sub r1,#1
	bl MAX7219Send
	add r1,#1

	ldr r0,=1
	ldr r4,=10
divideloop:
	cmp r0,r2
	bgt divideloop_end
	movs r3,r11
	sdiv r3,r3,r4
	mul r3,r3,r4
	subs r3,r11,r3
	sdiv r11,r11,r4
	movs r1,r3
	bl MAX7219Send
	adds r0,#1
	b divideloop
divideloop_end:
	pop {pc}

fib_cal:
	ldr r0,=fib_seq
	ldr r1,=0 //fib(n-1)
	ldr r2,=1 //fib(n)
	ldr r3,=4 //4*n
	ldr r4,=4 //4
	ldr r5,=1 //fib(n)
	str r2,[r0,r3]

fib_loop:
	add r3,r3,r4
	movs r5,r2
	add r2,r2,r1
	movs r1,r5
	str r2,[r0,r3]
	cmp r3,#160
	blt fib_loop
	bx lr

CheckPress:
	/* TODO: Do debounce and check button state */
	// check the state of button
	// if check '0' 20000 times, press=1
	ldr r0,=0
	ldr r1,=GPIOC_IDR
	ldr r3,=1
checkloop:
	adds r0,r0,r3
	ldr r4,=20000
	cmp r0,r4
	beq pushchecked
	ldr r2,[r1]
	lsr r2,#13
	and r2,r2,r3
	cmp r2,#0
	beq checkloop
	bx lr
pushchecked:
	adds r0,#1
	ldr r2,[r1]
	lsr r2,#13
	and r2,r2,r3
	cmp r2,#1
	bne pushchecked // if still push
	ldr r4,=200000
	cmp r0,r4
	blt presslessthan1sec
	ldr r10,=0 // reset the index of fib_seq
	ldr r12,=0 // reset the overflow
	bx lr
presslessthan1sec:
	ldr r9,=1
	bx lr
//

GPIO_init:
	//TODO: Initialize three GPIO pins as output for max7219 DIN, CS and CLK
	// Enable AHB2 clock
	ldr r0,=5
	ldr r1,=RCC_AHB2ENR
	str r0,[r1]

	// Set pins (PA5-7) as output mode
	ldr r1,=GPIOA_MODER
	ldr r2,[r1]
	and r2,#0xffff57ff
	str r2,[r1]

	// Set pin (PC13) as input mode
	movs r0,#0xf3ffffff
	ldr r1,=GPIOC_MODER
	ldr r2,[r1]
	and r2,r2,r0
	str r2,[r1]

	// Keep PUPDR as the default value(pull-up).
	movs r0,#0b0101010000000000
	ldr r1,=GPIOA_PUPDR
	str r0,[r1]
	movs r0,#0x4000000
	ldr r1,=GPIOC_PUPDR
	str r0,[r1]

	// Set output speed register as high speed
	movs r0,#0b1010100000000000 //101010000000
	ldr r1,=GPIOA_OSPEEDR
	str r0,[r1]
	movs r0,#0x8000000
	ldr r1,=GPIOC_OSPEEDR
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
	ldr r1,=0b11111111
	bl MAX7219Send

	//set display test
	ldr r0,=DISPLAYTEST
	ldr r1,=0
	bl MAX7219Send

	//set intensity
	ldr r0,=INTENSITY
	ldr r1,=0x0f
	bl MAX7219Send

	//set shutdown reg
	ldr r0,=SHUTDOWN
	ldr r1,=1
	bl MAX7219Send

	pop {r0,r1,pc}
