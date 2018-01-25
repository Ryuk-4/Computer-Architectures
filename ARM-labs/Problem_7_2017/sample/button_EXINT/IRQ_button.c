#include "button.h"
#include "lpc17xx.h"
#include "../led/led.h"

#define LD8 3  //on the board LD8 is equal to 3
#define ON 1
#define OFF 0

unsigned int current = LD8;
unsigned int status = ON;

void EINT0_IRQHandler (void)	  
{
	LED_Off(current);
	current = LD8;
	LED_On(current);
	status = ON;
	
  LPC_SC->EXTINT |= (1 << 0);     /* clear pending interrupt         */
	
}

//KEY1
void EINT1_IRQHandler (void)	  
{
	LED_Off(current);
	current++;

	if (current > 7)
		//current = 7;
		current = 0; //in order to make it sequential

	LED_On(current);
	status = ON;
	
  LPC_SC->EXTINT |= (1 << 1);     /* clear pending interrupt         */
	
}

//KEY2
void EINT2_IRQHandler (void)	  
{
	LED_Off(current);
  //since it will be always >= 0
  //an if-else is enough
	if(current > 0)
		current --;
	else
		current = 7; //in order to make it sequential
	LED_On(current);
	status = ON;
	
  LPC_SC->EXTINT |= (1 << 2);     /* clear pending interrupt         */
	

}


