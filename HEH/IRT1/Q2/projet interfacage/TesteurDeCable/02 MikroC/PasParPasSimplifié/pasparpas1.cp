#line 1 "C:/Users/Degueldre Ugo/Desktop/Nouveau dossier/PasParPas/pasparpas1.c"

int sortie;
int mode;

void pasparpas () {
 sortie = sortie*2;
 PORTB = sortie;

 RA0_bit = 0;
 delay_ms(500);
 if(sortie == 256) {
 sortie = 1;
 RA0_bit = 1;
 delay_ms(1000);
 }
 if(sortie == 0) {
 RA0_bit = 1 ;
 sortie = 1;
 delay_ms(500);

 }
}

void main() {
 TRISA = 0b00000010;
 PORTA = 0b11001000;
 TRISB = 0b00000001;
 PORTB = 0 ;
 pcon.OSCF = 1;
 CMCON = 0b00000111;
 sortie = 0;
 mode = -1 ;
 while(1){
 if(RB0_bit == 0){
 mode = 0;
 RA3_bit = 1;
 RA6_bit = 0;
 RA7_bit = 1 ;
 delay_ms(800);
 if(RB0_bit == 0){
 mode = 1;
 RA3_bit = 1;
 RA6_bit = 1;
 RA7_bit = 0 ;
 delay_ms(800);
 if(RB0_bit == 0){
 mode = 2;
 RA3_bit = 0;
 RA6_bit = 1;
 RA7_bit = 1 ;
 delay_ms(800);
 }


 }
 }
}
}
