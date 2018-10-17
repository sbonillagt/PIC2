DATO EQU 0X21
stepper	EQU 0X7E
CounterA EQU 0X24
CounterB EQU 0X25
CounterC EQU 0X26
PasosX EQU 0X27
PasosRegresoX EQU 0X28
PasosY EQU 0X29
PasosRegresoY EQU 0X30
NumeroIteracionesX EQU 0X31

IrMayorXIteracion EQU 32
IrMayorPasosX EQU 0X33
IrMayorPasosY EQU 0X34

INICIO
	ORG	0X00
	GOTO	START ;mueve el ip al punto de la etiqueta
START
	BSF	STATUS,	5
	CLRF	TRISB
	BCF	STATUS,	5
	MOVLW	4
	MOVWF	NumeroIteracionesX
	
	MOVLW	1 ; Moviendo a w El numero de iteraciones que vaya
	MOVWF	IrMayorXIteracion 
	MOVLW	60 ; Moviendo a w El numero de iteraciones que vaya
	MOVWF	IrMayorPasosX 
	MOVLW	45; Moviendo a W el numero de pasos que vaya en Y
	MOVWF	IrMayorPasosY 

	CALL	LOOPGENERALX
	CALL	IrMayorLuz;Moverme a Buscar LUz
	GOTO	SALIR	

LOOPGENERALX
	MOVLW	128
	MOVWF	PasosX
	MOVWF	PasosRegresoX
	CALL	FULLCLK
	MOVLW	128
	MOVWF	PasosY
	MOVWF	PasosRegresoY 
	CALL	CORRIDAY
	DECFSZ	NumeroIteracionesX, 1
	GOTO	LOOPGENERALX
	MOVLW	4
	MOVWF	NumeroIteracionesX
	GOTO	LOOPREGRESOX

LOOPREGRESOX
	MOVLW	128
	MOVWF	PasosRegresoX
	CALL	REGRESOX
	DECFSZ	NumeroIteracionesX, 1
	GOTO	LOOPREGRESOX
	GOTO	FIN

FULLCLK
	MOVLW	B'00001100'
	MOVWF	PORTB
	CALL	DelayOneSecond
	MOVLW	B'00000110'
	MOVWF	PORTB
	CALL	DelayOneSecond
	MOVLW	B'00000011'
	MOVWF	PORTB
	CALL	DelayOneSecond
	MOVLW	B'00001001'
	MOVWF	PORTB
	CALL	DelayOneSecond
	DECFSZ	PasosX,1
	GOTO	FULLCLK
	RETLW	B'00000000'

DelayOneSecond
	movlw D'1'
	movwf CounterC
	movlw D'4'
	movwf CounterB
	movlw D'4'
	movwf CounterA

loop
	decfsz CounterA,1
	goto loop
	decfsz CounterB,1
	goto loop
	decfsz CounterC,1
	goto loop
	RETLW	b'00000000'

REGRESOX
	MOVLW	B'00001001'
	MOVWF	PORTB
	CALL	DelayOneSecond
	MOVLW	B'00000011'
	MOVWF	PORTB
	CALL	DelayOneSecond
	MOVLW	B'00000110'
	MOVWF	PORTB
	CALL	DelayOneSecond
	MOVLW	B'00001100'
	MOVWF	PORTB
	CALL	DelayOneSecond
	DECFSZ	PasosRegresoX,1
	GOTO	REGRESOX
	RETLW	B'00000000'

CORRIDAY
   	MOVLW	B'11000000'
	MOVWF	PORTB
	CALL	DelayOneSecond
	MOVLW	B'01100000'
	MOVWF	PORTB
	CALL	DelayOneSecond
	MOVLW	B'00110000'
	MOVWF	PORTB
	CALL	DelayOneSecond
	MOVLW	B'10010000'
	MOVWF	PORTB
	CALL	DelayOneSecond
	DECFSZ	PasosY ,1
	GOTO	CORRIDAY
	GOTO	REGRESOY

REGRESOY
    	MOVLW	B'10010000'
	MOVWF	PORTB
	CALL	DelayOneSecond
	MOVLW	B'00110000'
	MOVWF	PORTB
	CALL	DelayOneSecond
	MOVLW	B'01100000'
	MOVWF	PORTB
	CALL	DelayOneSecond
	MOVLW	B'11000000'
	MOVWF	PORTB
	CALL	DelayOneSecond
	DECFSZ	PasosRegresoY ,1
	GOTO	REGRESOY
	RETLW	B'00000000'

FIN
	MOVLW	B'00000000'
	MOVWF	PORTB
	RETLW	B'00000000'
	;Call	IrMayorLuz


IrMayorLuz
	MOVLW	128
	MOVWF	PasosX
	CALL	FullMayorX
	DECFSZ	IrMayorXIteracion , 1
	GOTO	IrMayorLuz
	CALL	FullMayorY
	RETLW	B'00000000'

SALIR
	END
	GOTO SALIR

FullMayorX
	MOVLW	B'00001100'
	MOVWF	PORTB
	CALL	DelayOneSecond
	MOVLW	B'00000110'
	MOVWF	PORTB
	CALL	DelayOneSecond
	MOVLW	B'00000011'
	MOVWF	PORTB
	CALL	DelayOneSecond
	MOVLW	B'00001001'
	MOVWF	PORTB
	CALL	DelayOneSecond
	DECFSZ	PasosX,1
	GOTO	FullMayorX
	RETLW	B'00000000'

FullMayorY
   	MOVLW	B'11000000'
	MOVWF	PORTB
	CALL	DelayOneSecond
	MOVLW	B'01100000'
	MOVWF	PORTB
	CALL	DelayOneSecond
	MOVLW	B'00110000'
	MOVWF	PORTB
	CALL	DelayOneSecond
	MOVLW	B'10010000'
	MOVWF	PORTB
	CALL	DelayOneSecond
	DECFSZ	IrMayorPasosY ,1
	GOTO	FullMayorY
	RETLW	B'00000000'



