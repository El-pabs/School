
_boutonpasparpas:

;MyProject.c,4 :: 		void boutonpasparpas () {
;MyProject.c,5 :: 		compteur = compteur*2;
	MOVF       _compteur+0, 0
	MOVWF      R0+0
	MOVF       _compteur+1, 0
	MOVWF      R0+1
	RLF        R0+0, 1
	RLF        R0+1, 1
	BCF        R0+0, 0
	MOVF       R0+0, 0
	MOVWF      _compteur+0
	MOVF       R0+1, 0
	MOVWF      _compteur+1
;MyProject.c,6 :: 		PORTB = compteur;
	MOVF       R0+0, 0
	MOVWF      PORTB+0
;MyProject.c,8 :: 		RA0_bit = 0;
	BCF        RA0_bit+0, BitPos(RA0_bit+0)
;MyProject.c,9 :: 		delay_ms(500);
	MOVLW      3
	MOVWF      R11+0
	MOVLW      138
	MOVWF      R12+0
	MOVLW      85
	MOVWF      R13+0
L_boutonpasparpas0:
	DECFSZ     R13+0, 1
	GOTO       L_boutonpasparpas0
	DECFSZ     R12+0, 1
	GOTO       L_boutonpasparpas0
	DECFSZ     R11+0, 1
	GOTO       L_boutonpasparpas0
	NOP
	NOP
;MyProject.c,10 :: 		if(compteur == 256) {
	MOVF       _compteur+1, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L__boutonpasparpas40
	MOVLW      0
	XORWF      _compteur+0, 0
L__boutonpasparpas40:
	BTFSS      STATUS+0, 2
	GOTO       L_boutonpasparpas1
;MyProject.c,11 :: 		compteur = 1;
	MOVLW      1
	MOVWF      _compteur+0
	MOVLW      0
	MOVWF      _compteur+1
;MyProject.c,12 :: 		RA0_bit = 1;
	BSF        RA0_bit+0, BitPos(RA0_bit+0)
;MyProject.c,13 :: 		delay_ms(1000);
	MOVLW      6
	MOVWF      R11+0
	MOVLW      19
	MOVWF      R12+0
	MOVLW      173
	MOVWF      R13+0
L_boutonpasparpas2:
	DECFSZ     R13+0, 1
	GOTO       L_boutonpasparpas2
	DECFSZ     R12+0, 1
	GOTO       L_boutonpasparpas2
	DECFSZ     R11+0, 1
	GOTO       L_boutonpasparpas2
	NOP
	NOP
;MyProject.c,14 :: 		}
L_boutonpasparpas1:
;MyProject.c,15 :: 		if(compteur == 0) {
	MOVLW      0
	XORWF      _compteur+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__boutonpasparpas41
	MOVLW      0
	XORWF      _compteur+0, 0
L__boutonpasparpas41:
	BTFSS      STATUS+0, 2
	GOTO       L_boutonpasparpas3
;MyProject.c,16 :: 		RA0_bit = 1 ;
	BSF        RA0_bit+0, BitPos(RA0_bit+0)
;MyProject.c,17 :: 		compteur = 1;
	MOVLW      1
	MOVWF      _compteur+0
	MOVLW      0
	MOVWF      _compteur+1
;MyProject.c,18 :: 		delay_ms(500);
	MOVLW      3
	MOVWF      R11+0
	MOVLW      138
	MOVWF      R12+0
	MOVLW      85
	MOVWF      R13+0
L_boutonpasparpas4:
	DECFSZ     R13+0, 1
	GOTO       L_boutonpasparpas4
	DECFSZ     R12+0, 1
	GOTO       L_boutonpasparpas4
	DECFSZ     R11+0, 1
	GOTO       L_boutonpasparpas4
	NOP
	NOP
;MyProject.c,20 :: 		}
L_boutonpasparpas3:
;MyProject.c,21 :: 		}
L_end_boutonpasparpas:
	RETURN
; end of _boutonpasparpas

_BoucleInfinie:

;MyProject.c,23 :: 		void BoucleInfinie (){
;MyProject.c,24 :: 		delay_ms(500);
	MOVLW      3
	MOVWF      R11+0
	MOVLW      138
	MOVWF      R12+0
	MOVLW      85
	MOVWF      R13+0
L_BoucleInfinie5:
	DECFSZ     R13+0, 1
	GOTO       L_BoucleInfinie5
	DECFSZ     R12+0, 1
	GOTO       L_BoucleInfinie5
	DECFSZ     R11+0, 1
	GOTO       L_BoucleInfinie5
	NOP
	NOP
;MyProject.c,25 :: 		if(mode == 1) {
	MOVLW      0
	XORWF      _mode+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__BoucleInfinie43
	MOVLW      1
	XORWF      _mode+0, 0
L__BoucleInfinie43:
	BTFSS      STATUS+0, 2
	GOTO       L_BoucleInfinie6
;MyProject.c,26 :: 		compteur = compteur*2;
	MOVF       _compteur+0, 0
	MOVWF      R0+0
	MOVF       _compteur+1, 0
	MOVWF      R0+1
	RLF        R0+0, 1
	RLF        R0+1, 1
	BCF        R0+0, 0
	MOVF       R0+0, 0
	MOVWF      _compteur+0
	MOVF       R0+1, 0
	MOVWF      _compteur+1
;MyProject.c,27 :: 		PORTB = compteur;
	MOVF       R0+0, 0
	MOVWF      PORTB+0
;MyProject.c,28 :: 		RA0_bit = 0;
	BCF        RA0_bit+0, BitPos(RA0_bit+0)
;MyProject.c,29 :: 		delay_ms(250);
	MOVLW      2
	MOVWF      R11+0
	MOVLW      69
	MOVWF      R12+0
	MOVLW      169
	MOVWF      R13+0
L_BoucleInfinie7:
	DECFSZ     R13+0, 1
	GOTO       L_BoucleInfinie7
	DECFSZ     R12+0, 1
	GOTO       L_BoucleInfinie7
	DECFSZ     R11+0, 1
	GOTO       L_BoucleInfinie7
	NOP
	NOP
;MyProject.c,30 :: 		if(compteur == 256) {
	MOVF       _compteur+1, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L__BoucleInfinie44
	MOVLW      0
	XORWF      _compteur+0, 0
L__BoucleInfinie44:
	BTFSS      STATUS+0, 2
	GOTO       L_BoucleInfinie8
;MyProject.c,31 :: 		compteur =1;
	MOVLW      1
	MOVWF      _compteur+0
	MOVLW      0
	MOVWF      _compteur+1
;MyProject.c,32 :: 		RA0_bit = 1;
	BSF        RA0_bit+0, BitPos(RA0_bit+0)
;MyProject.c,33 :: 		delay_ms(250);
	MOVLW      2
	MOVWF      R11+0
	MOVLW      69
	MOVWF      R12+0
	MOVLW      169
	MOVWF      R13+0
L_BoucleInfinie9:
	DECFSZ     R13+0, 1
	GOTO       L_BoucleInfinie9
	DECFSZ     R12+0, 1
	GOTO       L_BoucleInfinie9
	DECFSZ     R11+0, 1
	GOTO       L_BoucleInfinie9
	NOP
	NOP
;MyProject.c,34 :: 		}
L_BoucleInfinie8:
;MyProject.c,35 :: 		if(compteur == 0) {
	MOVLW      0
	XORWF      _compteur+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__BoucleInfinie45
	MOVLW      0
	XORWF      _compteur+0, 0
L__BoucleInfinie45:
	BTFSS      STATUS+0, 2
	GOTO       L_BoucleInfinie10
;MyProject.c,36 :: 		RA0_bit = 1;
	BSF        RA0_bit+0, BitPos(RA0_bit+0)
;MyProject.c,37 :: 		compteur =1;
	MOVLW      1
	MOVWF      _compteur+0
	MOVLW      0
	MOVWF      _compteur+1
;MyProject.c,38 :: 		delay_ms(250);
	MOVLW      2
	MOVWF      R11+0
	MOVLW      69
	MOVWF      R12+0
	MOVLW      169
	MOVWF      R13+0
L_BoucleInfinie11:
	DECFSZ     R13+0, 1
	GOTO       L_BoucleInfinie11
	DECFSZ     R12+0, 1
	GOTO       L_BoucleInfinie11
	DECFSZ     R11+0, 1
	GOTO       L_BoucleInfinie11
	NOP
	NOP
;MyProject.c,39 :: 		}
L_BoucleInfinie10:
;MyProject.c,40 :: 		if (RB0_bit == 0){
	BTFSC      RB0_bit+0, BitPos(RB0_bit+0)
	GOTO       L_BoucleInfinie12
;MyProject.c,41 :: 		mode = 0;
	CLRF       _mode+0
	CLRF       _mode+1
;MyProject.c,42 :: 		}
L_BoucleInfinie12:
;MyProject.c,43 :: 		}
L_BoucleInfinie6:
;MyProject.c,44 :: 		}
L_end_BoucleInfinie:
	RETURN
; end of _BoucleInfinie

_BoucleInfinieSpeed:

;MyProject.c,45 :: 		void BoucleInfinieSpeed(){
;MyProject.c,47 :: 		if(mode == 2) {
	MOVLW      0
	XORWF      _mode+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__BoucleInfinieSpeed47
	MOVLW      2
	XORWF      _mode+0, 0
L__BoucleInfinieSpeed47:
	BTFSS      STATUS+0, 2
	GOTO       L_BoucleInfinieSpeed13
;MyProject.c,48 :: 		compteur = compteur*2;
	MOVF       _compteur+0, 0
	MOVWF      R1+0
	MOVF       _compteur+1, 0
	MOVWF      R1+1
	RLF        R1+0, 1
	RLF        R1+1, 1
	BCF        R1+0, 0
	MOVF       R1+0, 0
	MOVWF      _compteur+0
	MOVF       R1+1, 0
	MOVWF      _compteur+1
;MyProject.c,49 :: 		PORTB = compteur;
	MOVF       R1+0, 0
	MOVWF      PORTB+0
;MyProject.c,50 :: 		RA0_bit = 0;
	BCF        RA0_bit+0, BitPos(RA0_bit+0)
;MyProject.c,52 :: 		if(compteur == 256) {
	MOVF       R1+1, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L__BoucleInfinieSpeed48
	MOVLW      0
	XORWF      R1+0, 0
L__BoucleInfinieSpeed48:
	BTFSS      STATUS+0, 2
	GOTO       L_BoucleInfinieSpeed14
;MyProject.c,53 :: 		compteur =1;
	MOVLW      1
	MOVWF      _compteur+0
	MOVLW      0
	MOVWF      _compteur+1
;MyProject.c,54 :: 		RA0_bit = 1;
	BSF        RA0_bit+0, BitPos(RA0_bit+0)
;MyProject.c,56 :: 		}
L_BoucleInfinieSpeed14:
;MyProject.c,57 :: 		if(compteur == 0) {
	MOVLW      0
	XORWF      _compteur+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__BoucleInfinieSpeed49
	MOVLW      0
	XORWF      _compteur+0, 0
L__BoucleInfinieSpeed49:
	BTFSS      STATUS+0, 2
	GOTO       L_BoucleInfinieSpeed15
;MyProject.c,58 :: 		RA0_bit = 1;
	BSF        RA0_bit+0, BitPos(RA0_bit+0)
;MyProject.c,59 :: 		compteur =1;
	MOVLW      1
	MOVWF      _compteur+0
	MOVLW      0
	MOVWF      _compteur+1
;MyProject.c,61 :: 		}
L_BoucleInfinieSpeed15:
;MyProject.c,62 :: 		if (RB0_bit == 0){
	BTFSC      RB0_bit+0, BitPos(RB0_bit+0)
	GOTO       L_BoucleInfinieSpeed16
;MyProject.c,63 :: 		mode = 0;
	CLRF       _mode+0
	CLRF       _mode+1
;MyProject.c,64 :: 		}
L_BoucleInfinieSpeed16:
;MyProject.c,65 :: 		}
L_BoucleInfinieSpeed13:
;MyProject.c,66 :: 		}
L_end_BoucleInfinieSpeed:
	RETURN
; end of _BoucleInfinieSpeed

_Par2:

;MyProject.c,67 :: 		void Par2(){
;MyProject.c,68 :: 		if (mode==3){
	MOVLW      0
	XORWF      _mode+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__Par251
	MOVLW      3
	XORWF      _mode+0, 0
L__Par251:
	BTFSS      STATUS+0, 2
	GOTO       L_Par217
;MyProject.c,69 :: 		compteur = compteur*2;
	MOVF       _compteur+0, 0
	MOVWF      R0+0
	MOVF       _compteur+1, 0
	MOVWF      R0+1
	RLF        R0+0, 1
	RLF        R0+1, 1
	BCF        R0+0, 0
	MOVF       R0+0, 0
	MOVWF      _compteur+0
	MOVF       R0+1, 0
	MOVWF      _compteur+1
;MyProject.c,70 :: 		PORTB = compteur;
	MOVF       R0+0, 0
	MOVWF      PORTB+0
;MyProject.c,72 :: 		RA0_bit = 0;
	BCF        RA0_bit+0, BitPos(RA0_bit+0)
;MyProject.c,73 :: 		delay_ms(500);
	MOVLW      3
	MOVWF      R11+0
	MOVLW      138
	MOVWF      R12+0
	MOVLW      85
	MOVWF      R13+0
L_Par218:
	DECFSZ     R13+0, 1
	GOTO       L_Par218
	DECFSZ     R12+0, 1
	GOTO       L_Par218
	DECFSZ     R11+0, 1
	GOTO       L_Par218
	NOP
	NOP
;MyProject.c,74 :: 		if(compteur == 256) {
	MOVF       _compteur+1, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L__Par252
	MOVLW      0
	XORWF      _compteur+0, 0
L__Par252:
	BTFSS      STATUS+0, 2
	GOTO       L_Par219
;MyProject.c,75 :: 		compteur = 1;
	MOVLW      1
	MOVWF      _compteur+0
	MOVLW      0
	MOVWF      _compteur+1
;MyProject.c,76 :: 		RA0_bit = 1;
	BSF        RA0_bit+0, BitPos(RA0_bit+0)
;MyProject.c,77 :: 		delay_ms(1000);
	MOVLW      6
	MOVWF      R11+0
	MOVLW      19
	MOVWF      R12+0
	MOVLW      173
	MOVWF      R13+0
L_Par220:
	DECFSZ     R13+0, 1
	GOTO       L_Par220
	DECFSZ     R12+0, 1
	GOTO       L_Par220
	DECFSZ     R11+0, 1
	GOTO       L_Par220
	NOP
	NOP
;MyProject.c,78 :: 		}
L_Par219:
;MyProject.c,79 :: 		if(compteur == 0) {
	MOVLW      0
	XORWF      _compteur+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__Par253
	MOVLW      0
	XORWF      _compteur+0, 0
L__Par253:
	BTFSS      STATUS+0, 2
	GOTO       L_Par221
;MyProject.c,80 :: 		RA0_bit = 1 ;
	BSF        RA0_bit+0, BitPos(RA0_bit+0)
;MyProject.c,81 :: 		compteur = 1;
	MOVLW      1
	MOVWF      _compteur+0
	MOVLW      0
	MOVWF      _compteur+1
;MyProject.c,82 :: 		delay_ms(500);
	MOVLW      3
	MOVWF      R11+0
	MOVLW      138
	MOVWF      R12+0
	MOVLW      85
	MOVWF      R13+0
L_Par222:
	DECFSZ     R13+0, 1
	GOTO       L_Par222
	DECFSZ     R12+0, 1
	GOTO       L_Par222
	DECFSZ     R11+0, 1
	GOTO       L_Par222
	NOP
	NOP
;MyProject.c,84 :: 		}
L_Par221:
;MyProject.c,85 :: 		}
L_Par217:
;MyProject.c,86 :: 		}
L_end_Par2:
	RETURN
; end of _Par2

_main:

;MyProject.c,88 :: 		void main() {
;MyProject.c,89 :: 		TRISA = 0b00000000;
	CLRF       TRISA+0
;MyProject.c,90 :: 		PORTA = 0b11001000;
	MOVLW      200
	MOVWF      PORTA+0
;MyProject.c,91 :: 		TRISB = 0b00000001;
	MOVLW      1
	MOVWF      TRISB+0
;MyProject.c,92 :: 		PORTB = 0 ;
	CLRF       PORTB+0
;MyProject.c,93 :: 		pcon.OSCF = 1;
	BSF        PCON+0, 3
;MyProject.c,94 :: 		CMCON = 0b00000111;
	MOVLW      7
	MOVWF      CMCON+0
;MyProject.c,95 :: 		compteur = 0;
	CLRF       _compteur+0
	CLRF       _compteur+1
;MyProject.c,96 :: 		mode = -1 ;
	MOVLW      255
	MOVWF      _mode+0
	MOVLW      255
	MOVWF      _mode+1
;MyProject.c,98 :: 		RA1_bit = 1;
	BSF        RA1_bit+0, BitPos(RA1_bit+0)
;MyProject.c,99 :: 		delay_ms(500);
	MOVLW      3
	MOVWF      R11+0
	MOVLW      138
	MOVWF      R12+0
	MOVLW      85
	MOVWF      R13+0
L_main23:
	DECFSZ     R13+0, 1
	GOTO       L_main23
	DECFSZ     R12+0, 1
	GOTO       L_main23
	DECFSZ     R11+0, 1
	GOTO       L_main23
	NOP
	NOP
;MyProject.c,100 :: 		RA1_bit = 0;
	BCF        RA1_bit+0, BitPos(RA1_bit+0)
;MyProject.c,101 :: 		while(1){
L_main24:
;MyProject.c,102 :: 		if(RB0_bit == 0){
	BTFSC      RB0_bit+0, BitPos(RB0_bit+0)
	GOTO       L_main26
;MyProject.c,103 :: 		mode = 0;
	CLRF       _mode+0
	CLRF       _mode+1
;MyProject.c,104 :: 		RA3_bit = 0;
	BCF        RA3_bit+0, BitPos(RA3_bit+0)
;MyProject.c,105 :: 		RA6_bit = 1;
	BSF        RA6_bit+0, BitPos(RA6_bit+0)
;MyProject.c,106 :: 		RA7_bit = 1 ;
	BSF        RA7_bit+0, BitPos(RA7_bit+0)
;MyProject.c,107 :: 		delay_ms(800);
	MOVLW      5
	MOVWF      R11+0
	MOVLW      15
	MOVWF      R12+0
	MOVLW      241
	MOVWF      R13+0
L_main27:
	DECFSZ     R13+0, 1
	GOTO       L_main27
	DECFSZ     R12+0, 1
	GOTO       L_main27
	DECFSZ     R11+0, 1
	GOTO       L_main27
;MyProject.c,108 :: 		if(RB0_bit == 0){
	BTFSC      RB0_bit+0, BitPos(RB0_bit+0)
	GOTO       L_main28
;MyProject.c,109 :: 		mode = 1;
	MOVLW      1
	MOVWF      _mode+0
	MOVLW      0
	MOVWF      _mode+1
;MyProject.c,110 :: 		RA3_bit = 1;
	BSF        RA3_bit+0, BitPos(RA3_bit+0)
;MyProject.c,111 :: 		RA6_bit = 0;
	BCF        RA6_bit+0, BitPos(RA6_bit+0)
;MyProject.c,112 :: 		RA7_bit = 1 ;
	BSF        RA7_bit+0, BitPos(RA7_bit+0)
;MyProject.c,113 :: 		delay_ms(800);
	MOVLW      5
	MOVWF      R11+0
	MOVLW      15
	MOVWF      R12+0
	MOVLW      241
	MOVWF      R13+0
L_main29:
	DECFSZ     R13+0, 1
	GOTO       L_main29
	DECFSZ     R12+0, 1
	GOTO       L_main29
	DECFSZ     R11+0, 1
	GOTO       L_main29
;MyProject.c,114 :: 		if(RB0_bit == 0){
	BTFSC      RB0_bit+0, BitPos(RB0_bit+0)
	GOTO       L_main30
;MyProject.c,115 :: 		mode = 2;
	MOVLW      2
	MOVWF      _mode+0
	MOVLW      0
	MOVWF      _mode+1
;MyProject.c,116 :: 		RA3_bit = 1;
	BSF        RA3_bit+0, BitPos(RA3_bit+0)
;MyProject.c,117 :: 		RA6_bit = 1;
	BSF        RA6_bit+0, BitPos(RA6_bit+0)
;MyProject.c,118 :: 		RA7_bit = 0 ;
	BCF        RA7_bit+0, BitPos(RA7_bit+0)
;MyProject.c,119 :: 		delay_ms(800);
	MOVLW      5
	MOVWF      R11+0
	MOVLW      15
	MOVWF      R12+0
	MOVLW      241
	MOVWF      R13+0
L_main31:
	DECFSZ     R13+0, 1
	GOTO       L_main31
	DECFSZ     R12+0, 1
	GOTO       L_main31
	DECFSZ     R11+0, 1
	GOTO       L_main31
;MyProject.c,120 :: 		if(RB0_bit == 0){
	BTFSC      RB0_bit+0, BitPos(RB0_bit+0)
	GOTO       L_main32
;MyProject.c,121 :: 		mode = 3;
	MOVLW      3
	MOVWF      _mode+0
	MOVLW      0
	MOVWF      _mode+1
;MyProject.c,122 :: 		RA3_bit = 0;
	BCF        RA3_bit+0, BitPos(RA3_bit+0)
;MyProject.c,123 :: 		RA6_bit = 0;
	BCF        RA6_bit+0, BitPos(RA6_bit+0)
;MyProject.c,124 :: 		RA7_bit = 0;
	BCF        RA7_bit+0, BitPos(RA7_bit+0)
;MyProject.c,125 :: 		}
L_main32:
;MyProject.c,126 :: 		}
L_main30:
;MyProject.c,129 :: 		}
L_main28:
;MyProject.c,130 :: 		}
L_main26:
;MyProject.c,132 :: 		switch(mode){
	GOTO       L_main33
;MyProject.c,133 :: 		case 0:
L_main35:
;MyProject.c,134 :: 		boutonpasparpas(void);
	CALL       _boutonpasparpas+0
;MyProject.c,135 :: 		mode = -1;
	MOVLW      255
	MOVWF      _mode+0
	MOVLW      255
	MOVWF      _mode+1
;MyProject.c,136 :: 		break;
	GOTO       L_main34
;MyProject.c,137 :: 		case 1:
L_main36:
;MyProject.c,138 :: 		BoucleInfinie(void);
	CALL       _BoucleInfinie+0
;MyProject.c,139 :: 		break;
	GOTO       L_main34
;MyProject.c,140 :: 		case 2:
L_main37:
;MyProject.c,141 :: 		BoucleInfinieSpeed(void);
	CALL       _BoucleInfinieSpeed+0
;MyProject.c,142 :: 		break;
	GOTO       L_main34
;MyProject.c,143 :: 		case 3:
L_main38:
;MyProject.c,144 :: 		Par2(void);
	CALL       _Par2+0
;MyProject.c,145 :: 		break;
	GOTO       L_main34
;MyProject.c,146 :: 		}
L_main33:
	MOVLW      0
	XORWF      _mode+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main55
	MOVLW      0
	XORWF      _mode+0, 0
L__main55:
	BTFSC      STATUS+0, 2
	GOTO       L_main35
	MOVLW      0
	XORWF      _mode+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main56
	MOVLW      1
	XORWF      _mode+0, 0
L__main56:
	BTFSC      STATUS+0, 2
	GOTO       L_main36
	MOVLW      0
	XORWF      _mode+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main57
	MOVLW      2
	XORWF      _mode+0, 0
L__main57:
	BTFSC      STATUS+0, 2
	GOTO       L_main37
	MOVLW      0
	XORWF      _mode+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main58
	MOVLW      3
	XORWF      _mode+0, 0
L__main58:
	BTFSC      STATUS+0, 2
	GOTO       L_main38
L_main34:
;MyProject.c,147 :: 		}
	GOTO       L_main24
;MyProject.c,148 :: 		}
L_end_main:
	GOTO       $+0
; end of _main
