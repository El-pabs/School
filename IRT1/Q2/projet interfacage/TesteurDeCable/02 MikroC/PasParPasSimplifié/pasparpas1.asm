
_pasparpas:

;pasparpas1.c,5 :: 		void pasparpas () {
;pasparpas1.c,6 :: 		sortie = sortie*2;
	MOVF       _sortie+0, 0
	MOVWF      R0+0
	MOVF       _sortie+1, 0
	MOVWF      R0+1
	RLF        R0+0, 1
	RLF        R0+1, 1
	BCF        R0+0, 0
	MOVF       R0+0, 0
	MOVWF      _sortie+0
	MOVF       R0+1, 0
	MOVWF      _sortie+1
;pasparpas1.c,7 :: 		PORTB = sortie;
	MOVF       R0+0, 0
	MOVWF      PORTB+0
;pasparpas1.c,9 :: 		RA0_bit = 0;
	BCF        RA0_bit+0, BitPos(RA0_bit+0)
;pasparpas1.c,10 :: 		delay_ms(500);
	MOVLW      3
	MOVWF      R11+0
	MOVLW      138
	MOVWF      R12+0
	MOVLW      85
	MOVWF      R13+0
L_pasparpas0:
	DECFSZ     R13+0, 1
	GOTO       L_pasparpas0
	DECFSZ     R12+0, 1
	GOTO       L_pasparpas0
	DECFSZ     R11+0, 1
	GOTO       L_pasparpas0
	NOP
	NOP
;pasparpas1.c,11 :: 		if(sortie == 256) {
	MOVF       _sortie+1, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L__pasparpas14
	MOVLW      0
	XORWF      _sortie+0, 0
L__pasparpas14:
	BTFSS      STATUS+0, 2
	GOTO       L_pasparpas1
;pasparpas1.c,12 :: 		sortie = 1;
	MOVLW      1
	MOVWF      _sortie+0
	MOVLW      0
	MOVWF      _sortie+1
;pasparpas1.c,13 :: 		RA0_bit = 1;
	BSF        RA0_bit+0, BitPos(RA0_bit+0)
;pasparpas1.c,14 :: 		delay_ms(1000);
	MOVLW      6
	MOVWF      R11+0
	MOVLW      19
	MOVWF      R12+0
	MOVLW      173
	MOVWF      R13+0
L_pasparpas2:
	DECFSZ     R13+0, 1
	GOTO       L_pasparpas2
	DECFSZ     R12+0, 1
	GOTO       L_pasparpas2
	DECFSZ     R11+0, 1
	GOTO       L_pasparpas2
	NOP
	NOP
;pasparpas1.c,15 :: 		}
L_pasparpas1:
;pasparpas1.c,16 :: 		if(sortie == 0) {
	MOVLW      0
	XORWF      _sortie+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__pasparpas15
	MOVLW      0
	XORWF      _sortie+0, 0
L__pasparpas15:
	BTFSS      STATUS+0, 2
	GOTO       L_pasparpas3
;pasparpas1.c,17 :: 		RA0_bit = 1 ;
	BSF        RA0_bit+0, BitPos(RA0_bit+0)
;pasparpas1.c,18 :: 		sortie = 1;
	MOVLW      1
	MOVWF      _sortie+0
	MOVLW      0
	MOVWF      _sortie+1
;pasparpas1.c,19 :: 		delay_ms(500);
	MOVLW      3
	MOVWF      R11+0
	MOVLW      138
	MOVWF      R12+0
	MOVLW      85
	MOVWF      R13+0
L_pasparpas4:
	DECFSZ     R13+0, 1
	GOTO       L_pasparpas4
	DECFSZ     R12+0, 1
	GOTO       L_pasparpas4
	DECFSZ     R11+0, 1
	GOTO       L_pasparpas4
	NOP
	NOP
;pasparpas1.c,21 :: 		}
L_pasparpas3:
;pasparpas1.c,22 :: 		}
L_end_pasparpas:
	RETURN
; end of _pasparpas

_main:

;pasparpas1.c,24 :: 		void main() {
;pasparpas1.c,25 :: 		TRISA = 0b00000010;   // port A en sortie sauf RA1
	MOVLW      2
	MOVWF      TRISA+0
;pasparpas1.c,26 :: 		PORTA = 0b11001000;   // mettre les sortie à 0 sauf RA6, RA7, RA3
	MOVLW      200
	MOVWF      PORTA+0
;pasparpas1.c,27 :: 		TRISB = 0b00000001;   // port B en sortie sauf RB0
	MOVLW      1
	MOVWF      TRISB+0
;pasparpas1.c,28 :: 		PORTB = 0 ;           // mettre les sortie à zéro
	CLRF       PORTB+0
;pasparpas1.c,29 :: 		pcon.OSCF = 1;        // configure le pic a 4 MHz
	BSF        PCON+0, 3
;pasparpas1.c,30 :: 		CMCON = 0b00000111;   // desactive les comparateurs sur RA0
	MOVLW      7
	MOVWF      CMCON+0
;pasparpas1.c,31 :: 		sortie = 0;           // donne la valeur 0 à la variable output
	CLRF       _sortie+0
	CLRF       _sortie+1
;pasparpas1.c,32 :: 		mode = -1 ;           // donne la valeur -1 à la variable mode
	MOVLW      255
	MOVWF      _mode+0
	MOVLW      255
	MOVWF      _mode+1
;pasparpas1.c,33 :: 		while(1){           //boucle infini
L_main5:
;pasparpas1.c,34 :: 		if(RB0_bit == 0){
	BTFSC      RB0_bit+0, BitPos(RB0_bit+0)
	GOTO       L_main7
;pasparpas1.c,35 :: 		mode = 0;
	CLRF       _mode+0
	CLRF       _mode+1
;pasparpas1.c,36 :: 		RA3_bit = 1;
	BSF        RA3_bit+0, BitPos(RA3_bit+0)
;pasparpas1.c,37 :: 		RA6_bit = 0;
	BCF        RA6_bit+0, BitPos(RA6_bit+0)
;pasparpas1.c,38 :: 		RA7_bit = 1 ;
	BSF        RA7_bit+0, BitPos(RA7_bit+0)
;pasparpas1.c,39 :: 		delay_ms(800);
	MOVLW      5
	MOVWF      R11+0
	MOVLW      15
	MOVWF      R12+0
	MOVLW      241
	MOVWF      R13+0
L_main8:
	DECFSZ     R13+0, 1
	GOTO       L_main8
	DECFSZ     R12+0, 1
	GOTO       L_main8
	DECFSZ     R11+0, 1
	GOTO       L_main8
;pasparpas1.c,40 :: 		if(RB0_bit == 0){
	BTFSC      RB0_bit+0, BitPos(RB0_bit+0)
	GOTO       L_main9
;pasparpas1.c,41 :: 		mode = 1;
	MOVLW      1
	MOVWF      _mode+0
	MOVLW      0
	MOVWF      _mode+1
;pasparpas1.c,42 :: 		RA3_bit = 1;
	BSF        RA3_bit+0, BitPos(RA3_bit+0)
;pasparpas1.c,43 :: 		RA6_bit = 1;
	BSF        RA6_bit+0, BitPos(RA6_bit+0)
;pasparpas1.c,44 :: 		RA7_bit = 0 ;
	BCF        RA7_bit+0, BitPos(RA7_bit+0)
;pasparpas1.c,45 :: 		delay_ms(800);
	MOVLW      5
	MOVWF      R11+0
	MOVLW      15
	MOVWF      R12+0
	MOVLW      241
	MOVWF      R13+0
L_main10:
	DECFSZ     R13+0, 1
	GOTO       L_main10
	DECFSZ     R12+0, 1
	GOTO       L_main10
	DECFSZ     R11+0, 1
	GOTO       L_main10
;pasparpas1.c,46 :: 		if(RB0_bit == 0){
	BTFSC      RB0_bit+0, BitPos(RB0_bit+0)
	GOTO       L_main11
;pasparpas1.c,47 :: 		mode = 2;
	MOVLW      2
	MOVWF      _mode+0
	MOVLW      0
	MOVWF      _mode+1
;pasparpas1.c,48 :: 		RA3_bit = 0;
	BCF        RA3_bit+0, BitPos(RA3_bit+0)
;pasparpas1.c,49 :: 		RA6_bit = 1;
	BSF        RA6_bit+0, BitPos(RA6_bit+0)
;pasparpas1.c,50 :: 		RA7_bit = 1 ;
	BSF        RA7_bit+0, BitPos(RA7_bit+0)
;pasparpas1.c,51 :: 		delay_ms(800);
	MOVLW      5
	MOVWF      R11+0
	MOVLW      15
	MOVWF      R12+0
	MOVLW      241
	MOVWF      R13+0
L_main12:
	DECFSZ     R13+0, 1
	GOTO       L_main12
	DECFSZ     R12+0, 1
	GOTO       L_main12
	DECFSZ     R11+0, 1
	GOTO       L_main12
;pasparpas1.c,52 :: 		}
L_main11:
;pasparpas1.c,55 :: 		}
L_main9:
;pasparpas1.c,56 :: 		}
L_main7:
;pasparpas1.c,57 :: 		}
	GOTO       L_main5
;pasparpas1.c,58 :: 		}
L_end_main:
	GOTO       $+0
; end of _main
