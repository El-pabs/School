
_main:

;BoutonS_quence.c,4 :: 		void main() {
;BoutonS_quence.c,5 :: 		TRISA = 0b00000010; // port A en sortie sauf RA1
	MOVLW      2
	MOVWF      TRISA+0
;BoutonS_quence.c,6 :: 		PORTA = 0b11001000 ; // mettre les sorties à zéro sauf RA6, RA7,RA3
	MOVLW      200
	MOVWF      PORTA+0
;BoutonS_quence.c,7 :: 		TRISB = 0b00000001; // Port B en sortie sauf RB_0
	MOVLW      1
	MOVWF      TRISB+0
;BoutonS_quence.c,8 :: 		PORTB = 0 ; // mettre les sorties à zéro
	CLRF       PORTB+0
;BoutonS_quence.c,9 :: 		pcon.OSCF = 1; // configure le bit 3 du registre pcon pour 4 mhz
	BSF        PCON+0, 3
;BoutonS_quence.c,10 :: 		CMCON = 0b00000111; // désactiver les comparateurs sur RA0
	MOVLW      7
	MOVWF      CMCON+0
;BoutonS_quence.c,11 :: 		while(1)
L_main0:
;BoutonS_quence.c,13 :: 		if (RB0_bit==0) { // Si RB0 = 0 exécuter la ligne suivante
	BTFSC      RB0_bit+0, BitPos(RB0_bit+0)
	GOTO       L_main2
;BoutonS_quence.c,14 :: 		LED1(void) ; //Sous-programme LED1
	CALL       _LED1+0
;BoutonS_quence.c,15 :: 		} //fin du SI
L_main2:
;BoutonS_quence.c,16 :: 		}
	GOTO       L_main0
;BoutonS_quence.c,17 :: 		}
L_end_main:
	GOTO       $+0
; end of _main

_LED1:

;BoutonS_quence.c,20 :: 		void LED1(){ // début du Sous-programme LED1 ;
;BoutonS_quence.c,21 :: 		RA0_bit = 1 ;
	BSF        RA0_bit+0, BitPos(RA0_bit+0)
;BoutonS_quence.c,22 :: 		delay_ms(250);
	MOVLW      2
	MOVWF      R11+0
	MOVLW      69
	MOVWF      R12+0
	MOVLW      169
	MOVWF      R13+0
L_LED13:
	DECFSZ     R13+0, 1
	GOTO       L_LED13
	DECFSZ     R12+0, 1
	GOTO       L_LED13
	DECFSZ     R11+0, 1
	GOTO       L_LED13
	NOP
	NOP
;BoutonS_quence.c,23 :: 		RA0_bit = 0 ;
	BCF        RA0_bit+0, BitPos(RA0_bit+0)
;BoutonS_quence.c,24 :: 		RB1_bit = 1 ;
	BSF        RB1_bit+0, BitPos(RB1_bit+0)
;BoutonS_quence.c,25 :: 		delay_ms(250);
	MOVLW      2
	MOVWF      R11+0
	MOVLW      69
	MOVWF      R12+0
	MOVLW      169
	MOVWF      R13+0
L_LED14:
	DECFSZ     R13+0, 1
	GOTO       L_LED14
	DECFSZ     R12+0, 1
	GOTO       L_LED14
	DECFSZ     R11+0, 1
	GOTO       L_LED14
	NOP
	NOP
;BoutonS_quence.c,26 :: 		RB1_bit = 0 ;
	BCF        RB1_bit+0, BitPos(RB1_bit+0)
;BoutonS_quence.c,27 :: 		RB2_bit = 1 ;
	BSF        RB2_bit+0, BitPos(RB2_bit+0)
;BoutonS_quence.c,28 :: 		delay_ms(250);
	MOVLW      2
	MOVWF      R11+0
	MOVLW      69
	MOVWF      R12+0
	MOVLW      169
	MOVWF      R13+0
L_LED15:
	DECFSZ     R13+0, 1
	GOTO       L_LED15
	DECFSZ     R12+0, 1
	GOTO       L_LED15
	DECFSZ     R11+0, 1
	GOTO       L_LED15
	NOP
	NOP
;BoutonS_quence.c,29 :: 		RB2_bit = 0 ;
	BCF        RB2_bit+0, BitPos(RB2_bit+0)
;BoutonS_quence.c,30 :: 		RB3_bit = 1 ;
	BSF        RB3_bit+0, BitPos(RB3_bit+0)
;BoutonS_quence.c,31 :: 		delay_ms(250);
	MOVLW      2
	MOVWF      R11+0
	MOVLW      69
	MOVWF      R12+0
	MOVLW      169
	MOVWF      R13+0
L_LED16:
	DECFSZ     R13+0, 1
	GOTO       L_LED16
	DECFSZ     R12+0, 1
	GOTO       L_LED16
	DECFSZ     R11+0, 1
	GOTO       L_LED16
	NOP
	NOP
;BoutonS_quence.c,32 :: 		RB3_bit = 0 ;
	BCF        RB3_bit+0, BitPos(RB3_bit+0)
;BoutonS_quence.c,33 :: 		RB4_bit = 1 ;
	BSF        RB4_bit+0, BitPos(RB4_bit+0)
;BoutonS_quence.c,34 :: 		delay_ms(250);
	MOVLW      2
	MOVWF      R11+0
	MOVLW      69
	MOVWF      R12+0
	MOVLW      169
	MOVWF      R13+0
L_LED17:
	DECFSZ     R13+0, 1
	GOTO       L_LED17
	DECFSZ     R12+0, 1
	GOTO       L_LED17
	DECFSZ     R11+0, 1
	GOTO       L_LED17
	NOP
	NOP
;BoutonS_quence.c,35 :: 		RB4_bit = 0 ;
	BCF        RB4_bit+0, BitPos(RB4_bit+0)
;BoutonS_quence.c,36 :: 		RB5_bit = 1 ;
	BSF        RB5_bit+0, BitPos(RB5_bit+0)
;BoutonS_quence.c,37 :: 		delay_ms(250);
	MOVLW      2
	MOVWF      R11+0
	MOVLW      69
	MOVWF      R12+0
	MOVLW      169
	MOVWF      R13+0
L_LED18:
	DECFSZ     R13+0, 1
	GOTO       L_LED18
	DECFSZ     R12+0, 1
	GOTO       L_LED18
	DECFSZ     R11+0, 1
	GOTO       L_LED18
	NOP
	NOP
;BoutonS_quence.c,38 :: 		RB5_bit = 0 ;
	BCF        RB5_bit+0, BitPos(RB5_bit+0)
;BoutonS_quence.c,39 :: 		RB6_bit = 1 ;
	BSF        RB6_bit+0, BitPos(RB6_bit+0)
;BoutonS_quence.c,40 :: 		delay_ms(250);
	MOVLW      2
	MOVWF      R11+0
	MOVLW      69
	MOVWF      R12+0
	MOVLW      169
	MOVWF      R13+0
L_LED19:
	DECFSZ     R13+0, 1
	GOTO       L_LED19
	DECFSZ     R12+0, 1
	GOTO       L_LED19
	DECFSZ     R11+0, 1
	GOTO       L_LED19
	NOP
	NOP
;BoutonS_quence.c,41 :: 		RB6_bit = 0 ;
	BCF        RB6_bit+0, BitPos(RB6_bit+0)
;BoutonS_quence.c,42 :: 		RB7_bit = 1 ;
	BSF        RB7_bit+0, BitPos(RB7_bit+0)
;BoutonS_quence.c,43 :: 		delay_ms(250);
	MOVLW      2
	MOVWF      R11+0
	MOVLW      69
	MOVWF      R12+0
	MOVLW      169
	MOVWF      R13+0
L_LED110:
	DECFSZ     R13+0, 1
	GOTO       L_LED110
	DECFSZ     R12+0, 1
	GOTO       L_LED110
	DECFSZ     R11+0, 1
	GOTO       L_LED110
	NOP
	NOP
;BoutonS_quence.c,44 :: 		RB7_bit = 0 ;
	BCF        RB7_bit+0, BitPos(RB7_bit+0)
;BoutonS_quence.c,45 :: 		} // Fin du sous-programme LED1 ;
L_end_LED1:
	RETURN
; end of _LED1
