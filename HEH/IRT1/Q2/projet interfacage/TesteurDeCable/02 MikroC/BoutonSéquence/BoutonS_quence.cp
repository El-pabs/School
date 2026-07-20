#line 1 "C:/Users/Degueldre Ugo/Desktop/Nouveau dossier/BoutonS_quence.c"

 void LED1() ;

void main() {
TRISA = 0b00000010;
PORTA = 0b11001000 ;
TRISB = 0b00000001;
PORTB = 0 ;
pcon.OSCF = 1;
CMCON = 0b00000111;
 while(1)
 {
 if (RB0_bit==0) {
 LED1(void) ;
 }
 }
}


void LED1(){
 RA0_bit = 1 ;
 delay_ms(250);
 RA0_bit = 0 ;
 RB1_bit = 1 ;
 delay_ms(250);
 RB1_bit = 0 ;
 RB2_bit = 1 ;
 delay_ms(250);
 RB2_bit = 0 ;
 RB3_bit = 1 ;
 delay_ms(250);
 RB3_bit = 0 ;
 RB4_bit = 1 ;
 delay_ms(250);
 RB4_bit = 0 ;
 RB5_bit = 1 ;
 delay_ms(250);
 RB5_bit = 0 ;
 RB6_bit = 1 ;
 delay_ms(250);
 RB6_bit = 0 ;
 RB7_bit = 1 ;
 delay_ms(250);
 RB7_bit = 0 ;
}
