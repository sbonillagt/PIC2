ContadorBTN EQU 0X21
DatoEnE  EQU 0x22
INICIO
	ORG 0X00
	GOTO START
START
;CONFIGURACION DEL BOTON EN EL BIT 5 EN EL PUERTO C
	BSF STATUS, 5 ;PONE 1 EN STATUS BIT 5 PARA MOVERNOS AL BANCO 1
	CLRF TRISB; PONE EN 0 TRIS B Y LA BANDERA Z PONE SALIDA B 
	CLRW; LIMPIAR W 
	BCF STATUS, 5; PONE UN 0 EN BIT 5 Y NOS MOVEMOS AL BANCO 0 
	
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


	GOTO LEER_E_BTN

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
	GOTO  LEER_E_BTN
	;Mostrar el primer inciso
MOSTRAR2
;Al presionar la tecla cambiar� y deber� mostrar el n�mero del dispositivo con la mayor
;cantidad de luz.
	MOVLW B'00000010'
	MOVWF PORTB
	GOTO  LEER_E_BTN
	;Mostrar el segundo inciso
MOSTRAR3
;Al presionar la tecla cambiar� y deber� mostrar el n�mero del dispositivo con la menor
;cantidad de luz.
	MOVLW B'00000100'
	MOVWF PORTB
	GOTO  LEER_E_BTN
	;Mostrar el tercer inciso
MOSTRAR4
;Al presionar la tecla cambiar� y mostrar� cu�l es su n�mero de dispositivo
	MOVLW B'00001000'
	MOVWF PORTB
	;Mostrar el quinto inciso
	MOVLW B'00000000' 
	MOVWF ContadorBTN ;resetea el ContadorBTN para empezar de nuevo
	GOTO  LEER_E_BTN
	;Mostrar el cuarto inciso
