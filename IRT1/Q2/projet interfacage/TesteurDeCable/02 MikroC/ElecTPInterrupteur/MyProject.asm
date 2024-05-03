
_D1:

;MyProject.c,1 :: 		void D1() {
;MyProject.c,2 :: 		while(1){
L_D10:
;MyProject.c,3 :: 		RB3_bit=1;
	BSF        RB3_bit+0, BitPos(RB3_bit+0)
;MyProject.c,4 :: 		delay_ms(1000);
	MOVLW      6
	MOVWF      R11+0
	MOVLW      19
	MOVWF      R12+0
	MOVLW      173
	MOVWF      R13+0
L_D12:
	DECFSZ     R13+0, 1
	GOTO       L_D12
	DECFSZ     R12+0, 1
	GOTO       L_D12
	DECFSZ     R11+0, 1
	GOTO       L_D12
	NOP
	NOP
;MyProject.c,5 :: 		RB3_bit=0;
	BCF        RB3_bit+0, BitPos(RB3_bit+0)
;MyProject.c,6 :: 		delay_ms(1000);
	MOVLW      6
	MOVWF      R11+0
	MOVLW      19
	MOVWF      R12+0
	MOVLW      173
	MOVWF      R13+0
L_D13:
	DECFSZ     R13+0, 1
	GOTO       L_D13
	DECFSZ     R12+0, 1
	GOTO       L_D13
	DECFSZ     R11+0, 1
	GOTO       L_D13
	NOP
	NOP
;MyProject.c,7 :: 		}
	GOTO       L_D10
;MyProject.c,8 :: 		}
L_end_D1:
	RETURN
; end of _D1

_D2:

;MyProject.c,10 :: 		void D2(){
;MyProject.c,11 :: 		RB3_bit=0;
	BCF        RB3_bit+0, BitPos(RB3_bit+0)
;MyProject.c,12 :: 		RB4_bit=1;
	BSF        RB4_bit+0, BitPos(RB4_bit+0)
;MyProject.c,13 :: 		delay_ms(1000);
	MOVLW      6
	MOVWF      R11+0
	MOVLW      19
	MOVWF      R12+0
	MOVLW      173
	MOVWF      R13+0
L_D24:
	DECFSZ     R13+0, 1
	GOTO       L_D24
	DECFSZ     R12+0, 1
	GOTO       L_D24
	DECFSZ     R11+0, 1
	GOTO       L_D24
	NOP
	NOP
;MyProject.c,14 :: 		RB4_bit=0;
	BCF        RB4_bit+0, BitPos(RB4_bit+0)
;MyProject.c,15 :: 		}
L_end_D2:
	RETURN
; end of _D2

_interrupt:
	MOVWF      R15+0
	SWAPF      STATUS+0, 0
	CLRF       STATUS+0
	MOVWF      ___saveSTATUS+0
	MOVF       PCLATH+0, 0
	MOVWF      ___savePCLATH+0
	CLRF       PCLATH+0

;MyProject.c,16 :: 		void interrupt() {
;MyProject.c,17 :: 		D2(void);
	CALL       _D2+0
;MyProject.c,18 :: 		INTCON.RBIF=0;
	BCF        INTCON+0, 0
;MyProject.c,19 :: 		}
L_end_interrupt:
L__interrupt10:
	MOVF       ___savePCLATH+0, 0
	MOVWF      PCLATH+0
	SWAPF      ___saveSTATUS+0, 0
	MOVWF      STATUS+0
	SWAPF      R15+0, 1
	SWAPF      R15+0, 0
	RETFIE
; end of _interrupt

_main:

;MyProject.c,21 :: 		void main() {
;MyProject.c,22 :: 		TRISA=0b00000010;
	MOVLW      2
	MOVWF      TRISA+0
;MyProject.c,23 :: 		PORTA=0b11001000;
	MOVLW      200
	MOVWF      PORTA+0
;MyProject.c,24 :: 		TRISB=0b00000001;
	MOVLW      1
	MOVWF      TRISB+0
;MyProject.c,25 :: 		PORTB=0;
	CLRF       PORTB+0
;MyProject.c,26 :: 		pcon.OSCF=1;
	BSF        PCON+0, 3
;MyProject.c,27 :: 		CMCON=0b00000111;
	MOVLW      7
	MOVWF      CMCON+0
;MyProject.c,28 :: 		INTCON=0b10010000;
	MOVLW      144
	MOVWF      INTCON+0
;MyProject.c,29 :: 		OPTION_REG=0b01000000;
	MOVLW      64
	MOVWF      OPTION_REG+0
;MyProject.c,32 :: 		while(1) {
L_main5:
;MyProject.c,33 :: 		D1 (void);
	CALL       _D1+0
;MyProject.c,34 :: 		}
	GOTO       L_main5
;MyProject.c,35 :: 		}
L_end_main:
	GOTO       $+0
; end of _main
