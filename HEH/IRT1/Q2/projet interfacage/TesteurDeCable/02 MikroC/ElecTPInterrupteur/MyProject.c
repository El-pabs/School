void D1() {
while(1){
  RB3_bit=1;
  delay_ms(1000);
  RB3_bit=0;
  delay_ms(1000);
}
}

void D2(){
      RB3_bit=0;
      RB4_bit=1;
      delay_ms(1000);
      RB4_bit=0;
}
void interrupt() {
     D2(void);
     INTCON.RBIF=0;
}

void main() {
TRISA=0b00000010;
PORTA=0b11001000;
TRISB=0b00000001;
PORTB=0;
pcon.OSCF=1;
CMCON=0b00000111;
INTCON=0b10010000;
OPTION_REG=0b01000000;


while(1) {
    D1 (void);
    }
}