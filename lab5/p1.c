//These functions inside the arm file
extern void GPIO_init();
extern void max7219_init();
extern void max7219_send(unsigned char address, unsigned char
data);
/**
* TODO: Show data on 7-seg via max7219_send
* Input:
* data: decimal value
* num_digs: number of digits will show on 7-seg
* Return:
* 0: success
* -1: illegal data range(out of 8 digits range)
*/
int display(int data, int num_digs){
	int len;
	int CheckData;
	len = 0;
	CheckData = data;
	while(CheckData!=0){
		len++;
		CheckData /= 10;
	}
	if(len > num_digs) return -1;

	len++; //modify length to include 0
	while(len>1){
		max7219_send(8-len,data%10);
		len--;
		data /= 10;
	}
	max7219_send(8-len,0);
	return 0;
}

void main(){
	int student_id = 716088; //0 can't be the first digit
	GPIO_init();
	max7219_init();
	display(student_id, 8);
}
