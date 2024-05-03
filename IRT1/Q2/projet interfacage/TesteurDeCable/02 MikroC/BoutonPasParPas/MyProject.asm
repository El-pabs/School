
_main:

;MyProject.c,2 :: 		void main() {
;MyProject.c,3 :: 		TRISA = 0b00000010; //RA7 RA6 RA5 RA4 RA3 RA2 RA1 RA0
	MOVLW      2
	MOVWF      TRISA+0
;MyProject.c,4 :: 		PORTA = 0b11001000 ;
	MOVLW      200
	MOVWF      PORTA+0
;MyProject.c,5 :: 		TRISB = 0b00000001 ; //RB7 RB6 RB5 RB4 RB3 RB2 RB1 RB0
	MOVLW      1
	MOVWF      TRISB+0
;MyProject.c,6 :: 		PORTB = 0b00000000 ;
	CLRF       PORTB+0
;MyProject.c,7 :: 		pcon.OSCF = 1; // Configure l’oscillateur interne a 4MHz
	BSF        PCON+0, 3
;MyProject.c,8 :: 		CMCON = 0b00000111;
	MOVLW      7
	MOVWF      CMCON+0
;MyProject.c,10 :: 		while (1){
L_main0:
;MyProject.c,11 :: 		if (RB0_bit == 0){
	BTFSC      RB0_bit+0, BitPos(RB0_bit+0)
	GOTO       L_main2
;MyProject.c,12 :: 		RA3_bit = 1;
	BSF        RA3_bit+0, BitPos(RA3_bit+0)
;MyProject.c,13 :: 		compteur ++ ;
	INCF       _compteur+0, 1
	BTFSC      STATUS+0, 2
	INCF       _compteur+1, 1
;MyProject.c,14 :: 		}
L_main2:
;MyProject.c,16 :: 		if (compteur == 1){
	MOVLW      0
	XORWF      _compteur+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main22
	MOVLW      1
	XORWF      _compteur+0, 0
L__main22:
	BTFSS      STATUS+0, 2
	GOTO       L_main3
;MyProject.c,17 :: 		RA0_bit = 1 ;
	BSF        RA0_bit+0, BitPos(RA0_bit+0)
;MyProject.c,18 :: 		delay_ms(250);
	MOVLW      2
	MOVWF      R11+0
	MOVLW      69
	MOVWF      R12+0
	MOVLW      169
	MOVWF      R13+0
L_main4:
	DECFSZ     R13+0, 1
	GOTO       L_main4
	DECFSZ     R12+0, 1
	GOTO       L_main4
	DECFSZ     R11+0, 1
	GOTO       L_main4
	NOP
	NOP
;MyProject.c,19 :: 		}
L_main3:
;MyProject.c,21 :: 		if (compteur == 2){
	MOVLW      0
	XORWF      _compteur+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main23
	MOVLW      2
	XORWF      _compteur+0, 0
L__main23:
	BTFSS      STATUS+0, 2
	GOTO       L_main5
;MyProject.c,22 :: 		RA0_bit = 0;
	BCF        RA0_bit+0, BitPos(RA0_bit+0)
;MyProject.c,23 :: 		RB1_bit = 1 ;
	BSF        RB1_bit+0, BitPos(RB1_bit+0)
;MyProject.c,24 :: 		delay_ms(250);
	MOVLW      2
	MOVWF      R11+0
	MOVLW      69
	MOVWF      R12+0
	MOVLW      169
	MOVWF      R13+0
L_main6:
	DECFSZ     R13+0, 1
	GOTO       L_main6
	DECFSZ     R12+0, 1
	GOTO       L_main6
	DECFSZ     R11+0, 1
	GOTO       L_main6
	NOP
	NOP
;MyProject.c,25 :: 		}
L_main5:
;MyProject.c,27 :: 		if (compteur == 3){
	MOVLW      0
	XORWF      _compteur+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main24
	MOVLW      3
	XORWF      _compteur+0, 0
L__main24:
	BTFSS      STATUS+0, 2
	GOTO       L_main7
;MyProject.c,28 :: 		RB1_bit = 0;
	BCF        RB1_bit+0, BitPos(RB1_bit+0)
;MyProject.c,29 :: 		RB2_bit = 1 ;
	BSF        RB2_bit+0, BitPos(RB2_bit+0)
;MyProject.c,30 :: 		delay_ms(250);
	MOVLW      2
	MOVWF      R11+0
	MOVLW      69
	MOVWF      R12+0
	MOVLW      169
	MOVWF      R13+0
L_main8:
	DECFSZ     R13+0, 1
	GOTO       L_main8
	DECFSZ     R12+0, 1
	GOTO       L_main8
	DECFSZ     R11+0, 1
	GOTO       L_main8
	NOP
	NOP
;MyProject.c,31 :: 		}
L_main7:
;MyProject.c,33 :: 		if (compteur == 4){
	MOVLW      0
	XORWF      _compteur+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main25
	MOVLW      4
	XORWF      _compteur+0, 0
L__main25:
	BTFSS      STATUS+0, 2
	GOTO       L_main9
;MyProject.c,34 :: 		RB2_bit = 0;
	BCF        RB2_bit+0, BitPos(RB2_bit+0)
;MyProject.c,35 :: 		RB3_bit = 1 ;
	BSF        RB3_bit+0, BitPos(RB3_bit+0)
;MyProject.c,36 :: 		delay_ms(250);
	MOVLW      2
	MOVWF      R11+0
	MOVLW      69
	MOVWF      R12+0
	MOVLW      169
	MOVWF      R13+0
L_main10:
	DECFSZ     R13+0, 1
	GOTO       L_main10
	DECFSZ     R12+0, 1
	GOTO       L_main10
	DECFSZ     R11+0, 1
	GOTO       L_main10
	NOP
	NOP
;MyProject.c,37 :: 		}
L_main9:
;MyProject.c,39 :: 		if (compteur == 5){
	MOVLW      0
	XORWF      _compteur+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main26
	MOVLW      5
	XORWF      _compteur+0, 0
L__main26:
	BTFSS      STATUS+0, 2
	GOTO       L_main11
;MyProject.c,40 :: 		RB3_bit = 0;
	BCF        RB3_bit+0, BitPos(RB3_bit+0)
;MyProject.c,41 :: 		RB4_bit = 1 ;
	BSF        RB4_bit+0, BitPos(RB4_bit+0)
;MyProject.c,42 :: 		delay_ms(250);
	MOVLW      2
	MOVWF      R11+0
	MOVLW      69
	MOVWF      R12+0
	MOVLW      169
	MOVWF      R13+0
L_main12:
	DECFSZ     R13+0, 1
	GOTO       L_main12
	DECFSZ     R12+0, 1
	GOTO       L_main12
	DECFSZ     R11+0, 1
	GOTO       L_main12
	NOP
	NOP
;MyProject.c,43 :: 		}
L_main11:
;MyProject.c,45 :: 		if (compteur == 6){
	MOVLW      0
	XORWF      _compteur+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main27
	MOVLW      6
	XORWF      _compteur+0, 0
L__main27:
	BTFSS      STATUS+0, 2
	GOTO       L_main13
;MyProject.c,46 :: 		RB4_bit = 0;
	BCF        RB4_bit+0, BitPos(RB4_bit+0)
;MyProject.c,47 :: 		RB5_bit = 1 ;
	BSF        RB5_bit+0, BitPos(RB5_bit+0)
;MyProject.c,48 :: 		delay_ms(250);
	MOVLW      2
	MOVWF      R11+0
	MOVLW      69
	MOVWF      R12+0
	MOVLW      169
	MOVWF      R13+0
L_main14:
	DECFSZ     R13+0, 1
	GOTO       L_main14
	DECFSZ     R12+0, 1
	GOTO       L_main14
	DECFSZ     R11+0, 1
	GOTO       L_main14
	NOP
	NOP
;MyProject.c,49 :: 		}
L_main13:
;MyProject.c,51 :: 		if (compteur == 7){
	MOVLW      0
	XORWF      _compteur+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main28
	MOVLW      7
	XORWF      _compteur+0, 0
L__main28:
	BTFSS      STATUS+0, 2
	GOTO       L_main15
;MyProject.c,52 :: 		RB5_bit = 0;
	BCF        RB5_bit+0, BitPos(RB5_bit+0)
;MyProject.c,53 :: 		RB6_bit = 1 ;
	BSF        RB6_bit+0, BitPos(RB6_bit+0)
;MyProject.c,54 :: 		delay_ms(250);
	MOVLW      2
	MOVWF      R11+0
	MOVLW      69
	MOVWF      R12+0
	MOVLW      169
	MOVWF      R13+0
L_main16:
	DECFSZ     R13+0, 1
	GOTO       L_main16
	DECFSZ     R12+0, 1
	GOTO       L_main16
	DECFSZ     R11+0, 1
	GOTO       L_main16
	NOP
	NOP
;MyProject.c,55 :: 		}
L_main15:
;MyProject.c,57 :: 		if (compteur == 8){
	MOVLW      0
	XORWF      _compteur+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main29
	MOVLW      8
	XORWF      _compteur+0, 0
L__main29:
	BTFSS      STATUS+0, 2
	GOTO       L_main17
;MyProject.c,58 :: 		RB6_bit = 0;
	BCF        RB6_bit+0, BitPos(RB6_bit+0)
;MyProject.c,59 :: 		RB7_bit = 1 ;
	BSF        RB7_bit+0, BitPos(RB7_bit+0)
;MyProject.c,60 :: 		delay_ms(250);
	MOVLW      2
	MOVWF      R11+0
	MOVLW      69
	MOVWF      R12+0
	MOVLW      169
	MOVWF      R13+0
L_main18:
	DECFSZ     R13+0, 1
	GOTO       L_main18
	DECFSZ     R12+0, 1
	GOTO       L_main18
	DECFSZ     R11+0, 1
	GOTO       L_main18
	NOP
	NOP
;MyProject.c,61 :: 		}
L_main17:
;MyProject.c,63 :: 		if (compteur == 9){
	MOVLW      0
	XORWF      _compteur+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main30
	MOVLW      9
	XORWF      _compteur+0, 0
L__main30:
	BTFSS      STATUS+0, 2
	GOTO       L_main19
;MyProject.c,64 :: 		RB7_bit = 0;
	BCF        RB7_bit+0, BitPos(RB7_bit+0)
;MyProject.c,65 :: 		compteur = 0;
	CLRF       _compteur+0
	CLRF       _compteur+1
;MyProject.c,66 :: 		delay_ms(250);
	MOVLW      2
	MOVWF      R11+0
	MOVLW      69
	MOVWF      R12+0
	MOVLW      169
	MOVWF      R13+0
L_main20:
	DECFSZ     R13+0, 1
	GOTO       L_main20
	DECFSZ     R12+0, 1
	GOTO       L_main20
	DECFSZ     R11+0, 1
	GOTO       L_main20
	NOP
	NOP
;MyProject.c,67 :: 		}
L_main19:
;MyProject.c,68 :: 		}
	GOTO       L_main0
;MyProject.c,70 :: 		}
L_end_main:
	GOTO       $+0
; end of _main
