;**********************************************************************
;   This file is a basic code template for assembly code generation   *
;   on the PIC16F690. This file contains the basic code               *
;   building blocks to build upon.                                    *  
;                                                                     *
;   Refer to the MPASM User's Guide for additional information on     *
;   features of the assembler (Document DS33014).                     *
;                                                                     *
;   Refer to the respective PIC data sheet for additional             *
;   information on the instruction set.                               *
;                                                                     *
;**********************************************************************
;                                                                     *
;    Filename:	    Ashton Tran.asm                                   *
;    Date:                                                            *
;    File Version:                                                    *
;                                                                     *
;    Author:                                                          *
;    Company:                                                         *
;                                                                     * 
;                                                                     *
;**********************************************************************
;                                                                     *
;    Files Required: P16F690.INC                                      *
;                                                                     *
;**********************************************************************
;                                                                     *
;    Notes:                                                           *
;                                                                     *
;**********************************************************************


	list		p=16f690		; list directive to define processor
	#include	<P16F690.inc>		; processor specific variable definitions
	
	__CONFIG    _CP_OFF & _CPD_OFF & _BOR_OFF & _PWRTE_ON & _WDT_OFF & _INTRC_OSC_NOCLKOUT & _MCLRE_ON & _FCMEN_OFF & _IESO_OFF


; '__CONFIG' directive is used to embed configuration data within .asm file.
; The labels following the directive are located in the respective .inc file.
; See respective data sheet for additional information on configuration word.



;***** VARIABLE DEFINITIONS
w_temp		EQU	0x7D			; variable used for context saving
status_temp	EQU	0x7E			; variable used for context saving
pclath_temp	EQU	0x7F			; variable used for context saving

State   	EQU 0x20
testbit     EQU 0x21
portc  		EQU 0x22
count1     	EQU 0x23
count2      EQU 0x24
portb       EQU 0x25
;**********************************************************************
	ORG		0x000			; processor reset vector
  	goto	main			; go to beginning of program


	ORG		0x004			; interrupt vector location
	movwf		w_temp			; save off current W register contents
	movf		STATUS,w		; move status register into W register
	movwf		status_temp		; save off contents of STATUS register
	movf		PCLATH,w		; move pclath register into W register
	movwf		pclath_temp		; save off contents of PCLATH register


; isr code can go here or be located as a call subroutine elsewhere
  
	movlw  .15
	movwf  count1
	movwf  count2
LOOP   
	 DECFSZ  count1, 1       ;subtract 1 from 255 store new count in COUNT	
	goto	LOOP 			;if COUNT is zero, skip this instruction
	 DECFSZ   count2, 1 		;Subtract 1 from 255 	
	goto 	LOOP 			;go back to start of our loop 

	 btfss     PORTA,2       ; 
	goto      skip2
	 incf       State
	 movlw      0x0B
	 subwf      State,w
	 btfsc     STATUS,Z
	 clrf       State
skip2:	
    bcf        INTCON,1   ; external interupt occured on RA2

	movf		pclath_temp,w		; retrieve copy of PCLATH register
	movwf		PCLATH			; restore pre-isr PCLATH register contents	
	movf		status_temp,w		; retrieve copy of STATUS register
	movwf		STATUS			; restore pre-isr STATUS register contents
	swapf		w_temp,f
	swapf		w_temp,w		; restore pre-isr W register contents
	retfie					; return from interrupt



main 
	movlw    0x90    ; setup ra2 for interupt on change
	movwf    INTCON
	banksel  OPTION_REG
    clrf     OPTION_REG
 	banksel  ANSEL
    clrf     ANSEL    ; digital i/o
	
	banksel  TRISB
	clrf     TRISB
	clrf     PORTB	

	banksel  TRISA
	clrf     TRISA
	bsf      TRISA,RA2
    clrf     WPUA
	bsf      WPUA,WPUA2
	clrf     TRISC
	banksel  CM1CON0
    clrf     CM1CON0 
	banksel  PORTC
    clrf     State
	clrf     PORTC
 
 
;*************************************************************************
;		State Machine increment from 0 to 7
;*************************************************************************
;*************************************************************************
;		State Machine Steering
;*************************************************************************

SM_Steering
  		banksel State
		movf	State,w
		xorlw	D'1'
		btfsc	STATUS,Z
		goto	SM_State1
		banksel State
		movf	State,w
		xorlw	D'2'
		btfsc	STATUS,Z
		goto	SM_State2
		movf	State,w
		xorlw	D'3'
		btfsc	STATUS,Z
		goto	SM_State3
		movf	State,w
		xorlw	D'4'
		btfsc	STATUS,Z
		goto	SM_State4
		movf	State,w
		xorlw	D'5'
		btfsc	STATUS,Z
		goto	SM_State5
		movf	State,w
		xorlw	D'6'
		btfsc	STATUS,Z
		goto	SM_State6
		movf	State,w
		xorlw	D'7'
		btfsc	STATUS,Z
		goto	SM_State7
		movf	State,w
		xorlw	D'8'
		btfsc	STATUS,Z
		goto	SM_State8
	    movf	State,w
		xorlw	D'9'
		btfsc	STATUS,Z
		goto	SM_State9
		movf	State,w
		xorlw	D'10'
		btfsc	STATUS,Z
		goto	SM_State10

	goto   SM_Steering


;*************************************************************************
;		End of State Machine Steering
;*************************************************************************




SM_State1
  	CLRF    PORTB
	movlw   0x80 
	movwf   portc
	movf    portc,w
    movwf	PORTC
 
	goto	SM_Exit				;Exit State Machine		


SM_State2
   	movlw   0x40
	movwf   portc
	movf    portc,w
    movwf	PORTC
 
	goto	SM_Exit				;Exit State Machine			



SM_State3
 	movlw   0x20
	movwf   portc
	movf    portc,w
    movwf	PORTC
 
	goto	SM_Exit				;Exit State Machine		



SM_State4
  
 	movlw   0x10
	movwf   portc
	movf    portc,w
    movwf	PORTC
 
	goto	SM_Exit				;Exit State Machine			



SM_State5
  	movlw	0x08
	movwf   portc
	movf    portc,w
    movwf	PORTC
 
	goto	SM_Exit				;Exit State Machine		


SM_State6
   	movlw   0x04
	movwf   portc
	movf    portc,w
    movwf	PORTC
  
	goto	SM_Exit				;Exit State Machine		


SM_State7
   	movlw	0x02
	movwf   portc
	movf    portc,w
    movwf	PORTC

	goto	SM_Exit				;Exit State Machine	


SM_State8
  	movlw   0x01
	movwf   portc
	movf    portc,w
    movwf	PORTC

	goto	SM_Exit				;Exit State Machine	

 
SM_State9
	BANKSEL portb
	CLRF    PORTC
	BANKSEL PORTB
    
	movlw   0x20
	movwf   portb
	movf    portb,W
	movwf   PORTB


	goto    SM_Exit


SM_State10
  	BANKSEL portb
	BANKSEL PORTB
	movlw   0x1
	movwf   portb
	movf    portb,w
    movwf	PORTB

	goto	SM_Exit				;Exit State Machine	

 
;*************************************************************************
;		State Machine Exit
;*************************************************************************

SM_Exit

;*************************************************************************
;		End Of State Machine 
;*************************************************************************
  
	goto SM_Steering 
	 

 

END                       ; directive 'end of program'

