// Prototypes
 void LED1() ; // Sous-programme LED1
//*********************************************
void main() {
TRISA = 0b00000010; // port A en sortie sauf RA1
PORTA = 0b11001000 ; // mettre les sorties à zéro sauf RA6, RA7,RA3
TRISB = 0b00000001; // Port B en sortie sauf RB_0
PORTB = 0 ; // mettre les sorties à zéro
pcon.OSCF = 1; // configure le bit 3 du registre pcon pour 4 mhz
CMCON = 0b00000111; // désactiver les comparateurs sur RA0
 while(1)
 {
 if (RB0_bit==0) { // Si RB0 = 0 exécuter la ligne suivante
 LED1(void) ; //Sous-programme LED1
 } //fin du SI
 }
}
//*********************************************
//sous-programme
void LED1(){ // début du Sous-programme LED1 ;
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
} // Fin du sous-programme LED1 ;