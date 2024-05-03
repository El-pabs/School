int compteur = 0;
void main() {
TRISA = 0b00000010; //RA7 RA6 RA5 RA4 RA3 RA2 RA1 RA0
PORTA = 0b11001000 ;
TRISB = 0b00000001 ; //RB7 RB6 RB5 RB4 RB3 RB2 RB1 RB0
PORTB = 0b00000000 ;
pcon.OSCF = 1; // Configure l’oscillateur interne a 4MHz
CMCON = 0b00000111;

      while (1){
            if (RB0_bit == 0){
            RA3_bit = 1;
            compteur ++ ;
            }
            
            if (compteur == 1){
            RA0_bit = 1 ;
            delay_ms(250);
            }
            
            if (compteur == 2){
            RA0_bit = 0;
            RB1_bit = 1 ;
            delay_ms(250);
            }
            
            if (compteur == 3){
            RB1_bit = 0;
            RB2_bit = 1 ;
            delay_ms(250);
            }
            
            if (compteur == 4){
            RB2_bit = 0;
            RB3_bit = 1 ;
            delay_ms(250);
            }
            
            if (compteur == 5){
            RB3_bit = 0;
            RB4_bit = 1 ;
            delay_ms(250);
            }
            
            if (compteur == 6){
            RB4_bit = 0;
            RB5_bit = 1 ;
            delay_ms(250);
            }
            
            if (compteur == 7){
            RB5_bit = 0;
            RB6_bit = 1 ;
            delay_ms(250);
            }
            
            if (compteur == 8){
            RB6_bit = 0;
            RB7_bit = 1 ;
            delay_ms(250);
            }
            
            if (compteur == 9){
            RB7_bit = 0;
            compteur = 0;
            delay_ms(250);
            }
      }

}