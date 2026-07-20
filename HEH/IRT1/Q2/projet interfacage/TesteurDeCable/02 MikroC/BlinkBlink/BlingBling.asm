
_main:

;BlingBling.c,1 :: 		void main() {
;BlingBling.c,2 :: 		TRISA = 0b00000010; //RA7 RA6 RA5 RA4 RA3 RA2 RA1 RA0
	MOVLW      2
	MOVWF      TRISA+0
;BlingBling.c,3 :: 		PORTA = 0b00000000 ;
	CLRF       PORTA+0
;BlingBling.c,4 :: 		TRISB = 0b00000001 ; //RB7 RB6 RB5 RB4 RB3 RB2 RB1 RB0
	MOVLW      1
	MOVWF      TRISB+0
;BlingBling.c,5 :: 		PORTB = 0b00000000 ;
	CLRF       PORTB+0
;BlingBling.c,6 :: 		pcon.OSCF = 1; // Configure l’oscillateur interne a 4MHz
	BSF        PCON+0, 3
;BlingBling.c,7 :: 		while (1){
L_main0:
;BlingBling.c,8 :: 		RB4_bit = 1;  // Mettre la sortie à 1
	BSF        RB4_bit+0, BitPos(RB4_bit+0)
;BlingBling.c,9 :: 		delay_ms(1000);
	MOVLW      6
	MOVWF      R11+0
	MOVLW      19
	MOVWF      R12+0
	MOVLW      173
	MOVWF      R13+0
L_main2:
	DECFSZ     R13+0, 1
	GOTO       L_main2
	DECFSZ     R12+0, 1
	GOTO       L_main2
	DECFSZ     R11+0, 1
	GOTO       L_main2
	NOP
	NOP
;BlingBling.c,10 :: 		RB4_bit = 0;  // Mettre la sortie à 0
	BCF        RB4_bit+0, BitPos(RB4_bit+0)
;BlingBling.c,11 :: 		delay_ms(1000);
	MOVLW      6
	MOVWF      R11+0
	MOVLW      19
	MOVWF      R12+0
	MOVLW      173
	MOVWF      R13+0
L_main3:
	DECFSZ     R13+0, 1
	GOTO       L_main3
	DECFSZ     R12+0, 1
	GOTO       L_main3
	DECFSZ     R11+0, 1
	GOTO       L_main3
	NOP
	NOP
;BlingBling.c,12 :: 		}
	GOTO       L_main0
;BlingBling.c,13 :: 		}
L_end_main:
	GOTO       $+0
; end of _main
