#include "stm32l476xx.h"
//TODO: define your gpio pin

#define X0 0b0001 //GPIO_Pin_0
#define X1 0b0010 //GPIO_Pin_1
#define X2 0b0100 //GPIO_Pin_2
#define X3 0b1000 //GPIO_Pin_3

#define Y0 0b1000 //GPIO_Pin_0
#define Y1 0b10000 //GPIO_Pin_1
#define Y2 0b100000 //GPIO_Pin_2
#define Y3 0b1000000 //GPIO_Pin_3

unsigned int x_pin[4] = {X0, X1, X2, X3}; //PC0123
unsigned int y_pin[4] = {Y0, Y1, Y2, Y3}; //PB3456

extern void GPIO_init();
extern void max7219_init();
extern void max7219_send(unsigned char address, unsigned char
data);

/* TODO: initial keypad gpio pin, X as input and Y as output */
void keypad_init(int inv){
	if(!inv){
		//output gpio pin PB3456
		//RCC is set in gpio_init
		GPIOB->MODER = GPIOB->MODER & 0xFFFFC03F;
		GPIOB->MODER = GPIOB->MODER | 0x0000D570;
		GPIOB->PUPDR = GPIOB->PUPDR & 0xFFFFC03F;
		GPIOB->PUPDR = GPIOB->PUPDR | 0x0000D570; //pull-up
		GPIOB->OSPEEDR = GPIOB->OSPEEDR | 0x01540;
		GPIOB->ODR = 0;

		//input gpio pin PC0-3
		GPIOC->MODER = GPIOC->MODER & 0xFFFFFF00;
		GPIOC->PUPDR = GPIOC->PUPDR & 0xFFFFFF00; //pull-down
		GPIOC->PUPDR = GPIOC->PUPDR | 0x000000AA;
		GPIOC->OSPEEDR = GPIOC->OSPEEDR | 0xAA;
		GPIOC->IDR = 0;

	}else{
		//input gpio pin PB3456
		//RCC is set in gpio_init
		GPIOB->MODER = GPIOB->MODER & 0xFFFFC03F;
		GPIOB->PUPDR = GPIOB->PUPDR & 0xFFFFC03F; //pull-down
		GPIOB->PUPDR = GPIOB->PUPDR | 0x0000EABF;
		GPIOB->OSPEEDR = GPIOB->OSPEEDR | 0x01540;
		GPIOB->IDR = 0;

		//output gpio pin PC0-3
		GPIOC->MODER = GPIOC->MODER & 0xFFFFFF00;
		GPIOC->MODER = GPIOC->MODER | 0x00000055;
		GPIOC->PUPDR = GPIOC->PUPDR & 0xFFFFFF00; //pull-up
		GPIOC->PUPDR = GPIOC->PUPDR | 0x00000055;
		GPIOC->OSPEEDR = GPIOC->OSPEEDR | 0xAA;
		GPIOC->ODR = 0;

	}
}

int GPIO_ReadInput(GPIO_TypeDef *a, uint8_t b){
	return a->IDR & b;
}

/* TODO: scan keypad value
return: >=0: key-value pressed¡A-1: keypad is free
*/
int res1,res2,press_cnt;
int grid[4][4]={
	1,2,3,10,
	4,5,6,11,
	7,8,9,12,
	15,0,14,13
};
//int first,sec; //live coding
int keypad_scan(){
	int cnt1=0,cnt2=0;
	res1=res2=0;
	for(int i=0;i<4;i++){
		GPIOB->BSRR = y_pin[i];
		for(int j=0;j<4;j++){
			if(i==j) continue;
			GPIOB->BRR = y_pin[j];
		}
		if(GPIO_ReadInput(GPIOC,x_pin[0])) //check row 1
			res1+= grid[0][i],cnt1++;
		if(GPIO_ReadInput(GPIOC,x_pin[1])) //check row 2
			res1+= grid[1][i],cnt1++;
		if(GPIO_ReadInput(GPIOC,x_pin[2])) //check row 3
			res1+= grid[2][i],cnt1++;
		if(GPIO_ReadInput(GPIOC,x_pin[3])) //check row 4
			res1+= grid[3][i],cnt1++;
	}
	keypad_init(1);
	for(int i=0;i<4;i++){
		GPIOC->BSRR = x_pin[i];
		for(int j=0;j<4;j++){
			if(i==j) continue;
			GPIOC->BRR = x_pin[j];
		}
		if(GPIO_ReadInput(GPIOB,y_pin[0])) //check col 1
			res2+= grid[i][0],cnt2++;
		if(GPIO_ReadInput(GPIOB,y_pin[1])) //check col 2
			res2+= grid[i][1],cnt2++;
		if(GPIO_ReadInput(GPIOB,y_pin[2])) //check col 3
			res2+= grid[i][2],cnt2++;
		if(GPIO_ReadInput(GPIOB,y_pin[3])) //check col 4
			res2+= grid[i][3],cnt2++;
	}
	keypad_init(0);
	//if(cnt1==0 && cnt2==0) first=sec=-1; //live coding
	//else if(first==-1 && cnt1==1) first=res1; //live coding
	//else if(first==-1 && cnt2==1) first=res2; //live coding
	//else if(sec==-1 && cnt1==2) sec=res1-first; //live coding
	//else if(sec==-1 && cnt2==2) sec=res2-first; //live coding

	//if(cnt1==cnt2 && cnt1==1 && first!=-1 && sec!=-1) first=res1, sec=-1; //live coding

	if(cnt1==cnt2 && cnt1==0) return -1;
	else if(cnt1==2) return res1;
	else if(cnt2==2) return res2;
	else return res1==res2?res1:res1+res2;
}

int main(){
	GPIO_init();
	max7219_init();
	keypad_init(0);
	int num_ans;
	while(1){
		num_ans = keypad_scan();
		keypad_init(0);
		int num_tem = num_ans,len = 0;
		//int len_ans, len_fir, len_sec; //live coding
		//len_ans = (num_ans>=10?2:1); //live coding
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
			/*if(first!=-1 && sec!=-1){ //live coding start
                 len_fir=(first>=10?2:1);
                 len_sec=(sec>=10?2:1);

                 int Fir=first,Sec=sec,ptr=len_ans+1;
                 while(len_sec){
                     ptr++;
                     max7219_send(ptr,Sec%10);
                     Sec/=10;len_sec--;
                 }
                 ptr++;
                 while(len_fir){
                     ptr++;
                     max7219_send(ptr,Fir%10);
                     Fir/=10;len_fir--;
                 }
             }
			else{
                 for(int i=8;i>len_ans;i--) max7219_send(i,0xf);
            }*/ //live coding end
		}
		else {
			for(int i=8;i>=1;i--) max7219_send(i,0xf);
		}
	}
	return 0;
}
