;DECLARACIONES VARIABLES
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
IrMayorPasosY EQU 0X34

INICIO
;Inicio del programa ASIGNACIONES VARIABLES
	ORG	0X00

;Seteo PUERTO B para los motores
	BSF	STATUS,	5
	CLRF	TRISB
	BCF	STATUS,	5
	MOVLW	4
	MOVWF	NumeroIteracionesX

;PRUEBA para regresar el motor al mayor de luz  ELIMINAR
	MOVLW	1 ; Moviendo a w El numero de iteraciones que vaya
	MOVWF	IrMayorXIteracion 
	MOVLW	45; Moviendo a W el numero de pasos que vaya en Y
	MOVWF	IrMayorPasosY 

	GOTO	MENU ;mueve el ip al punto de la etiqueta

;--------------------------MENU PROGRAMA-------------------------------
MENU 
	CALL	LOOP_GENERAL
	CALL	IrMayorLuz;Moverme a Buscar LUz
	GOTO	SALIR	

LOOP_GENERAL
	MOVLW	128
	MOVWF	PasosX
	MOVWF	PasosRegresoX
	CALL	MOVER_X
	MOVLW	128
	MOVWF	PasosY
	MOVWF	PasosRegresoY 
	CALL	CORRIDAY
	DECFSZ	NumeroIteracionesX, 1
	GOTO	LOOP_GENERAL
	MOVLW	4
	MOVWF	NumeroIteracionesX
	GOTO	LOOP_REGRESO_X

LOOP_REGRESO_X
	MOVLW	128
	MOVWF	PasosRegresoX
	CALL	REGRESOX
	DECFSZ	NumeroIteracionesX, 1
	GOTO	LOOP_REGRESO_X
	;GOTO	FIN
	RETLW	B'00000000'

MOVER_X
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
	GOTO	MOVER_X
	RETLW	B'00000000'

DelayOneSecond
	movlw D'1'
	movwf CounterC
	movlw D'4'
	movwf CounterB
	movlw D'4'
	movwf CounterA

Loop_Delay
	decfsz CounterA,1
	goto Loop_Delay
	decfsz CounterB,1
	goto Loop_Delay
	decfsz CounterC,1
	goto Loop_Delay
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

FIN ; NO se utiliza esta etiqueta se comenta en linea 62 
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




