#line 1 "C:/Users/Degueldre Ugo/Desktop/Nouveau dossier/BlingBling.c"
void main() {
TRISA = 0b00000010;
PORTA = 0b00000000 ;
TRISB = 0b00000001 ;
PORTB = 0b00000000 ;
pcon.OSCF = 1;
 while (1){
 RB4_bit = 1;
 delay_ms(1000);
 RB4_bit = 0;
 delay_ms(1000);
 }
}
