
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
  TRISA = 0b00000010;   // port A en sortie sauf RA1
  PORTA = 0b11001000;   // mettre les sortie à 0 sauf RA6, RA7, RA3
  TRISB = 0b00000001;   // port B en sortie sauf RB0
  PORTB = 0 ;           // mettre les sortie à zéro
  pcon.OSCF = 1;        // configure le pic a 4 MHz
  CMCON = 0b00000111;   // desactive les comparateurs sur RA0
  sortie = 0;           // donne la valeur 0 à la variable output
  mode = -1 ;           // donne la valeur -1 à la variable mode
  while(1){           //boucle infini
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