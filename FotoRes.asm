ADC EQU 0x20
CON EQU 0X21
CON2 EQU 0X22
CON3 EQU 0X23
MAYOR_LUZR EQU 0x24
MENOR_LUZR EQU 0x25
CATEGORIA EQU 0X26

	org 0x00 ;Inicio del programa en la posici?n cero de memoria
	nop ;Libre (uso del debugger)

_inicio
	bcf STATUS,RP0 ;Ir banco 0
	bcf STATUS,RP1
	movlw b'01000001' ;A/D conversion Fosc/8
	movwf ADCON0
	;     	     7     6     5    4    3    2       1 0
	; 1Fh ADCON0 ADCS1 ADCS0 CHS2 CHS1 CHS0 GO/DONE ? ADON
	bsf STATUS,RP0 ;Ir banco 1
	bcf STATUS,RP1
	movlw b'00000111'
	movwf OPTION_REG ;TMR0 preescaler, 1:156
	;                7    6      5    4    3   2   1   0 
	; 81h OPTION_REG RBPU INTEDG T0CS T0SE PSA PS2 PS1 PS0
	movlw b'00001110' ;A/D Port AN0/RA0
	movwf ADCON1
	;            7    6     5 4 3     2     1     0 
	; 9Fh ADCON1 ADFM ADCS2 ? ? PCFG3 PCFG2 PCFG1 PCFG0
	bsf TRISA,0 ;RA0 linea de entrada para el ADC
	clrf TRISB
	bcf STATUS,RP0 ;Ir banco 0
	bcf STATUS,RP1
	clrf PORTB ;Limpiar PORTB

FotoResistencia
	CALL _bucle
	MOVF	CATEGORIA,W
	MOVWF	PORTB
	GOTO FotoResistencia

_bucle
	;btfss INTCON,T0IF
	;goto _bucle ;Esperar que el timer0 desborde
	; SE DEBE DE COLOCAR UN DELAY PARA QUE ESPERE LA CONVERSION
	BSF  STATUS,Z
	CALL _PRESPERA
	bcf INTCON,T0IF ;Limpiar el indicador de desborde
	bsf ADCON0,GO ;Comenzar conversion A/D
_espera
	btfsc ADCON0,GO ;ADCON0 es 0? (la conversion esta completa?)
	goto _espera ;No, ir _espera
	movf ADRESH,W ;Si, W=ADRESH
	; 1Eh ADRESH A/D Result Register High Byte
	; 9Eh ADRESL A/D Result Register Low Byte 
	movwf ADC ;ADC=W
	;rrf ADC,F ;ADC /4
	;rrf ADC,F
	;bcf ADC,7
	;bcf ADC,6
	movfw ADC ;W = ADC
	;movwf PORTB ;PORTB = W
	CALL INTERVALOS
	CALL COMPARACION_Foto
	RETURN
	movlw D'32' ;Comparamos el valor del ADC para saber si es menor que 128
	subwf ADC,W
	;btfss STATUS,C ;Es mayor a 128?
	goto _desactivar ;No, desactivar RB7
	bsf PORTC,7 ;Si, RB7 = 1 logico
	goto _bucle ;Ir bucle
_desactivar
	bcf PORTB,7 ;RB7 = 0 logico
	goto _bucle ;Ir bucle
	
_PRESPERA
	MOVLW 0XFF
	MOVWF CON
	MOVWF CON2
	MOVWF CON3	
	CALL ESPE
	RETURN	

ESPE
	DECFSZ	CON,0X01
	GOTO	ESPE
	CALL	ESPE2
	RETURN
ESPE2
	DECFSZ	CON2,0X01
	GOTO	ESPE2
	CALL	ESPE3
	RETURN
ESPE3
	DECFSZ	CON3,0X01
	GOTO	ESPE3
	RETURN

INTERVALOS
	MOVLW	D'9'
	MOVWF	CATEGORIA

	movlw	d'210'
	subwf	ADC, 0
	BTFSc	STATUS, C
	RETURN

	DECF	categoria,1
	movlw	d'194'
	subwf	ADC, 0
	BTFSC STATUS, C
	return

	DECF	categoria,1
	movlw	d'174'
	subwf	ADC, 0
	BTFSC STATUS, C
	return

	DECF	categoria,1
	movlw	d'158'
	subwf	ADC, 0
	BTFSC STATUS, C
	return

	DECF	categoria,1
	movlw	d'138'
	subwf	ADC, 0
	BTFSC STATUS, C
	return

	DECF	categoria,1
	movlw	d'117'
	subwf	ADC, 0
	BTFSC STATUS, C
	return

	DECF	categoria,1
	movlw	d'82'
	subwf	ADC, 0
	BTFSC STATUS, C
	return

	DECF	categoria,1
	movlw	d'51'
	subwf	ADC, 0
	BTFSC STATUS, C
	return

	DECF	categoria,1
	movlw	d'28'
	subwf	ADC, 0
	BTFSC STATUS, C
	return
	
	DECF	categoria, 1
	return

COMPARACION_Foto	
	MOVF	CATEGORIA,W
	SUBWF	MENOR_LUZR,W	
	BTFSC	STATUS,C
	CALL	EntradaMenor

	MOVF	CATEGORIA,W
	SUBWF	MAYOR_LUZR,W
	BTFSS	STATUS,C
	CALL 	EntradaMayor

	RETURN

EntradaMayor
	MOVF	CATEGORIA,W
	MOVWF	MAYOR_LUZR
	MOVLW	B'00000001'
	MOVWF	PORTD
	RETURN

EntradaMenor
	MOVF	CATEGORIA,W
	MOVWF	MENOR_LUZR
	MOVLW	B'00000010'
	MOVWF	PORTD
	RETURN
end