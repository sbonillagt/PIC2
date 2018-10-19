;DECLARACIONES VARIABLES
;DATO EQU 0X21
;stepper	EQU 0X7E
;------------------------------ VARIABLES MOTORES INICIO --------------------------------------
CounterA EQU 0X21
CounterB EQU 0X22
CounterC EQU 0X23

PasosX EQU 0X24                     ;Pasos que dara el motor por iteracion
PasosRegresoX EQU 0X25              ;Pasos que hara en el regreso para llegar posicion inical
PasosY EQU 0X26                     ;Pasos en Y para formar 0 a 90 grados
PasosRegresoY EQU 0X27              ;Pasos Regreso en Y de 90 a 0
NumeroIteracionesX EQU 0X28         ;Numero de veces que va hacer la iteracion de 90 (90*4 = 360)

IrMayorXIteracion EQU 0X29          ;Guardar posicion de la iteracion en X donde encuentre mayor luz
IrMayorPasosY EQU 0X2A              ;Guardar posicion (pasos) en Y donde encuentre mas luz

;------------------------------ VARIABLES BOTON MOSTRAR INICIO --------------------------------------
ContadorBTN EQU 0X2B
DatoEnE  EQU 0X2C
NumGrupo  EQU 0X2D


INICIO
;Inicio del programa ASIGNACIONES VARIABLES
	ORG	0X00

;------------------------CONFIGURACIONES PUERTOS --------------------------------------
;------------------------------ PUERTO A y E --------------------------------------
	MOVLW b'00000000'
	MOVWF ContadorBTN

	BSF     STATUS,RP0
    	BCF     STATUS,RP1
    	MOVLW   D'14'
    	MOVWF   ADCON1
	MOVLW	B'111'
    	MOVWF   TRISE
    	BCF     STATUS,RP0
    	BCF     STATUS,RP1

    	MOVLW   D'7'
    	MOVWF   NumGrupo
;------------------------------ PUERTO B --------------------------------------
	BSF STATUS, 5 ;PONE 1 EN STATUS BIT 5 PARA MOVERNOS AL BANCO 1
	CLRF TRISB; PONE EN 0 TRIS B Y LA BANDERA Z PONE SALIDA B 
	CLRW; LIMPIAR W 
	BCF STATUS, 5; PONE UN 0 EN BIT 5 Y NOS MOVEMOS AL BANCO 0 
	MOVLW	4
	MOVWF	NumeroIteracionesX
;------------------------------ PUERTO D --------------------------------------








;PRUEBA para regresar el motor al mayor de luz  ELIMINAR
	MOVLW	1 ; Moviendo a w El numero de iteraciones que vaya
	MOVWF	IrMayorXIteracion 
	MOVLW	45; Moviendo a W el numero de pasos que vaya en Y
	MOVWF	IrMayorPasosY 

	GOTO	MENU ;mueve el ip al punto de la etiqueta

;--------------------------MENU PROGRAMA-------------------------------
MENU 
	;CALL	LOOP_GENERAL ; Mover Motores y buscar mayor luz 
	;CALL	IrMayorLuz;Moverme a Buscar LUz
	GOTO	LEER_E_BTN
	GOTO	SALIR	


;------------------------------ MOTORES INICIO --------------------------------------
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

;------------------------------ BOTON E 0 INICIAL -----------------------------------------
LEER_E_BTN
	MOVF PORTE, W ;Movemos lo de PUERTO E hacia W
	MOVWF DatoEnE ;Movemos la variable hacia dato en E
	MOVLW B'001' ; MOVEMOS A W EL 0 BIT de E  
	SUBWF DatoEnE,W ;VA A RESTARLE AL DATO E LO QUE ESTA EN W
	BTFSC STATUS, Z ; VERIFICA QUE EL STATUS DE LA OPERACION SEA 0 
	GOTO  CONTAR ; SI LA OPERACION ES 0 SE VA A UN CONTAR
	GOTO  LEER_E_BTN ;REGRESA LOOP LEER

CONTAR
	INCF  ContadorBTN, 0 ;incrementa e ContadorBTN en 1
	MOVWF ContadorBTN
	MOVLW b'00000001'
	SUBWF ContadorBTN,W
	BTFSC STATUS, Z
	GOTO  MOSTRAR1

	MOVLW b'00000010'
	SUBWF ContadorBTN,W
	BTFSC STATUS, Z
	GOTO  MOSTRAR2

	MOVLW b'00000011'
	SUBWF ContadorBTN,W
	BTFSC STATUS, Z
	GOTO  MOSTRAR3

	MOVLW b'00000100'
	SUBWF ContadorBTN, 0
	BTFSC STATUS, Z
	GOTO  MOSTRAR4

MOSTRAR1
;Al iniciar, mostrar cu�nto es el �ndice de luz (escala definida por el grupo)
	MOVLW B'00000001'
	MOVWF PORTB
	CALL	DelayOneSecond
	CALL	DelayOneSecond
	CALL	DelayOneSecond
	CALL	DelayOneSecond
	CALL	DelayOneSecond
	GOTO  LEER_E_BTN
	;Mostrar el primer inciso
MOSTRAR2
;Al presionar la tecla cambiar� y deber� mostrar el n�mero del dispositivo con la mayor
;cantidad de luz.
	MOVLW B'00000010'
	MOVWF PORTB
	CALL	DelayOneSecond
	CALL	DelayOneSecond
	CALL	DelayOneSecond
	CALL	DelayOneSecond
	CALL	DelayOneSecond
	GOTO  LEER_E_BTN
	;Mostrar el segundo inciso
MOSTRAR3
;Al presionar la tecla cambiar� y deber� mostrar el n�mero del dispositivo con la menor
;cantidad de luz.
	MOVLW B'00000100'
	MOVWF PORTB
	CALL	DelayOneSecond
	CALL	DelayOneSecond
	CALL	DelayOneSecond
	CALL	DelayOneSecond
	CALL	DelayOneSecond
	GOTO  LEER_E_BTN
	;Mostrar el tercer inciso
MOSTRAR4
;Al presionar la tecla cambiar� y mostrar� cu�l es su n�mero de dispositivo
	MOVLW B'00001000'
	MOVWF PORTB
	CALL	DelayOneSecond
	CALL	DelayOneSecond
	CALL	DelayOneSecond
	CALL	DelayOneSecond
	CALL	DelayOneSecond
	;Mostrar el quinto inciso
	MOVLW B'00000000' 
	MOVWF ContadorBTN ;resetea el ContadorBTN para empezar de nuevo
	GOTO  LEER_E_BTN
	;Mostrar el cuarto inciso
