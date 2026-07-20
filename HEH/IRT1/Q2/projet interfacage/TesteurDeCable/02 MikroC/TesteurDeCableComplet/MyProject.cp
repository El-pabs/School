#line 1 "C:/Users/Degueldre Ugo/Desktop/DegueldreUgoIRT1GR4/02 MikroC/TesteurDeCableComplet/MyProject.c"
int compteur;
int mode;

void boutonpasparpas () {
 compteur = compteur*2;
 PORTB = compteur;

 RA0_bit = 0;
 delay_ms(500);
 if(compteur == 256) {
 compteur = 1;
 RA0_bit = 1;
 delay_ms(1000);
 }
 if(compteur == 0) {
 RA0_bit = 1 ;
 compteur = 1;
 delay_ms(500);

 }
}

void BoucleInfinie (){
 delay_ms(500);
 if(mode == 1) {
 compteur = compteur*2;
 PORTB = compteur;
 RA0_bit = 0;
 delay_ms(250);
 if(compteur == 256) {
 compteur =1;
 RA0_bit = 1;
 delay_ms(250);
 }
 if(compteur == 0) {
 RA0_bit = 1;
 compteur =1;
 delay_ms(250);
 }
 if (RB0_bit == 0){
 mode = 0;
 }
 }
}
void BoucleInfinieSpeed(){

 if(mode == 2) {
 compteur = compteur*2;
 PORTB = compteur;
 RA0_bit = 0;

 if(compteur == 256) {
 compteur =1;
 RA0_bit = 1;

 }
 if(compteur == 0) {
 RA0_bit = 1;
 compteur =1;

 }
 if (RB0_bit == 0){
 mode = 0;
 }
 }
}
void Par2(){
 if (mode==3){
 compteur = compteur*2;
 PORTB = compteur;

 RA0_bit = 0;
 delay_ms(500);
 if(compteur == 256) {
 compteur = 1;
 RA0_bit = 1;
 delay_ms(1000);
 }
 if(compteur == 0) {
 RA0_bit = 1 ;
 compteur = 1;
 delay_ms(500);

 }
 }
}

void main() {
 TRISA = 0b00000000;
 PORTA = 0b11001000;
 TRISB = 0b00000001;
 PORTB = 0 ;
 pcon.OSCF = 1;
 CMCON = 0b00000111;
 compteur = 0;
 mode = -1 ;

 RA1_bit = 1;
 delay_ms(500);
 RA1_bit = 0;
 while(1){
 if(RB0_bit == 0){
 mode = 0;
 RA3_bit = 0;
 RA6_bit = 1;
 RA7_bit = 1 ;
 delay_ms(800);
 if(RB0_bit == 0){
 mode = 1;
 RA3_bit = 1;
 RA6_bit = 0;
 RA7_bit = 1 ;
 delay_ms(800);
 if(RB0_bit == 0){
 mode = 2;
 RA3_bit = 1;
 RA6_bit = 1;
 RA7_bit = 0 ;
 delay_ms(800);
 if(RB0_bit == 0){
 mode = 3;
 RA3_bit = 0;
 RA6_bit = 0;
 RA7_bit = 0;
 }
 }


 }
 }

 switch(mode){
 case 0:
 boutonpasparpas(void);
 mode = -1;
 break;
 case 1:
 BoucleInfinie(void);
 break;
 case 2:
 BoucleInfinieSpeed(void);
 break;
 case 3:
 Par2(void);
 break;
 }
 }
}
