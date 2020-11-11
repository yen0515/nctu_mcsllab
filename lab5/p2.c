#include "stm32l476xx.h"
//TODO: define your gpio pin

#define X0 0b0001 //GPIO_Pin_0
#define X1 0b0010 //GPIO_Pin_1
#define X2 0b0100 //GPIO_Pin_2
#define X3 0b1000 //GPIO_Pin_3

#define Y0 0b0001 //GPIO_Pin_0
#define Y1 0b0010 //GPIO_Pin_1
#define Y2 0b100000000 //GPIO_Pin_2
#define Y3 0b1000000000 //GPIO_Pin_3

unsigned int x_pin[4] = {X0, X1, X2, X3}; //PC0123
unsigned int y_pin[4] = {Y0, Y1, Y2, Y3}; //PA0123

extern void GPIO_init();
extern void max7219_init();
extern void max7219_send(unsigned char address, unsigned char
data);

/* TODO: initial keypad gpio pin, X as input and Y as output */
void keypad_init(){
	//output gpio pin PA0189
	//RCC is set in gpio_init
	GPIOA->MODER = GPIOA->MODER & 0xFFF0FFF0;
	GPIOA->MODER = GPIOA->MODER | 0x00050005;
	GPIOA->PUPDR = GPIOA->PUPDR | 0xFFF5FFF5; //pull-up
	GPIOA->OSPEEDR = GPIOA->OSPEEDR | 0x50005;
	GPIOA->ODR = GPIOA->ODR | 0xF000F;

	//input gpio pin PC0-3
	GPIOC->MODER = GPIOC->MODER & 0xFFFFFF00;
	GPIOC->PUPDR = GPIOC->PUPDR | 0xFFFFFFAA; //pull-down
	GPIOC->OSPEEDR = GPIOC->OSPEEDR | 0x55;
}

int GPIO_ReadInput(GPIO_TypeDef *a, uint8_t b){
	return a->IDR & b;
}


/* TODO: scan keypad value
return: >=0: key-value pressed¡A-1: keypad is free
*/
 int keypad_scan(){
	GPIOA->BSRR = y_pin[0]; //check column 1
	GPIOA->BRR = y_pin[1];
	GPIOA->BRR = y_pin[2];
	GPIOA->BRR = y_pin[3];

	if(GPIO_ReadInput(GPIOC,x_pin[0])) //check row 1
		return 1;
	if(GPIO_ReadInput(GPIOC,x_pin[1])) //check row 2
		return 4;
	if(GPIO_ReadInput(GPIOC,x_pin[2])) //check row 3
		return 7;
	if(GPIO_ReadInput(GPIOC,x_pin[3])) //check row 4
		return 15;

	GPIOA->BSRR = y_pin[1]; //check column 2
	GPIOA->BRR = y_pin[0];
	GPIOA->BRR = y_pin[2];
	GPIOA->BRR = y_pin[3];

	if(GPIO_ReadInput(GPIOC,x_pin[0]))
		return 2;
	if(GPIO_ReadInput(GPIOC,x_pin[1]))
		return 5;
	if(GPIO_ReadInput(GPIOC,x_pin[2]))
		return 8;
	if(GPIO_ReadInput(GPIOC,x_pin[3]))
		return 0;

	GPIOA->BSRR = y_pin[2]; //check column 3
	GPIOA->BRR = y_pin[0];
	GPIOA->BRR = y_pin[1];
	GPIOA->BRR = y_pin[3];

	if(GPIO_ReadInput(GPIOC,x_pin[0]))
		return 3;
	if(GPIO_ReadInput(GPIOC,x_pin[1]))
		return 6;
	if(GPIO_ReadInput(GPIOC,x_pin[2]))
		return 9;
	if(GPIO_ReadInput(GPIOC,x_pin[3]))
		return 14;

	GPIOA->BSRR = y_pin[3]; //check column 4
	GPIOA->BRR = y_pin[0];
	GPIOA->BRR = y_pin[1];
	GPIOA->BRR = y_pin[2];

	if(GPIO_ReadInput(GPIOC,x_pin[0]))
		return 10;
	if(GPIO_ReadInput(GPIOC,x_pin[1]))
		return 11;
	if(GPIO_ReadInput(GPIOC,x_pin[2]))
		return 12;
	if(GPIO_ReadInput(GPIOC,x_pin[3]))
		return 13;

	 return -1;
}

int main(){
	GPIO_init();
	max7219_init();
	keypad_init();
	int num_ans;
	while(1){
		num_ans = keypad_scan();
		int num_tem = num_ans,len = 0;
		if(num_ans>=0){ //keypad is pressed
			while(num_tem!=0){
				num_tem/=10;
				len++;
			}
			if(len==1){
				max7219_send(2,0xF);
				max7219_send(len,num_ans);
			}
			else if(len==0){ //the output is 0
				max7219_send(2,0xF);
				max7219_send(1,0);
			}
			else {
				while(len>0){
					max7219_send(3-len,num_ans%10);
					num_ans/=10;
					len--;
				}
			}
		}
		else {
			max7219_send(1,0xF);
			max7219_send(2,0xF);
		}
	}
	return 0;
}
