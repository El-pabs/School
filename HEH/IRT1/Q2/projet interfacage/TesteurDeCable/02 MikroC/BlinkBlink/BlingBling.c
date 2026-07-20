void main() {
TRISA = 0b00000010; //RA7 RA6 RA5 RA4 RA3 RA2 RA1 RA0
PORTA = 0b00000000 ;
TRISB = 0b00000001 ; //RB7 RB6 RB5 RB4 RB3 RB2 RB1 RB0
PORTB = 0b00000000 ;
pcon.OSCF = 1; // Configure l’oscillateur interne a 4MHz
          while (1){
                RB4_bit = 1;  // Mettre la sortie à 1
                delay_ms(1000);
                RB4_bit = 0;  // Mettre la sortie à 0
                delay_ms(1000);
          }
}