Contador EQU 0X21
DatoEnD  EQU 0x22
INICIO
	ORG 0X00
	GOTO START
START
;CONFIGURACION DEL BOTON EN EL BIT 5 EN EL PUERTO C
	BSF STATUS, 5 ;PONE 1 EN STATUS BIT 5 PARA MOVERNOS AL BANCO 1
	CLRF TRISB; PONE EN 0 TRIS B Y LA BANDERA Z
	;CLRF TRISD; PONE EN 0 TRIS B Y LA BANDERA Z
	MOVLW B'00100000' ; LA ENTRADA 5 EN PUERTO C HABILITADA
	MOVWF TRISD; HABILITAMOS EL BIT 5 EN C 
	;MOVLW B'001'
	;MOVWF TRISE
	CLRW; LIMPIAR W 
	BCF STATUS, 5; PONE UN 0 EN BIT 5 Y NOS MOVEMOS AL BANCO 0 
	MOVLW b'00000000'
	MOVWF Contador


	BSF     STATUS,RP0
    	BCF     STATUS,RP1
    	MOVLW   D'14'
    	MOVWF   ADCON1
	MOVLW	B'111'
    	MOVWF   TRISE
    	BCF     STATUS,RP0
    	BCF     STATUS,RP1


	GOTO LEERD

LEERD;LEEMOS PUERTO C
	MOVF PORTE, W ; MOVEMOS LA ENTRADA DEL PUERTO C HACIA W 
	MOVWF DatoEnD ; movemos la variable hacia dato en c
	MOVLW B'00000001' ;MOVEMOS A W EL 5 BIT  
	SUBWF DatoEnD,W ;VA A RESTARLE AL DATO LO QUE ESTA EN W
	BTFSC STATUS, Z ; VERIFICA QUE EL STATUS DE LA OPERACION SEA 0 
	GOTO  CONTAR ; SI LA OPERACION ES 0 SE VA A UN CONTAR
	GOTO  LEERD ;REGRESA LOOP LEER
CONTAR
	INCF  Contador, 0 ;incrementa e contador en 1
	MOVWF Contador
	MOVLW b'00000001'
	SUBWF Contador,W
	BTFSC STATUS, Z
	GOTO  MOSTRAR1

	MOVLW b'00000010'
	SUBWF Contador,W
	BTFSC STATUS, Z
	GOTO  MOSTRAR2

	MOVLW b'00000011'
	SUBWF Contador,W
	BTFSC STATUS, Z
	GOTO  MOSTRAR3

	MOVLW b'00000100'
	SUBWF Contador, 0
	BTFSC STATUS, Z
	GOTO  MOSTRAR4

MOSTRAR1
;Al iniciar, mostrar cu�nto es el �ndice de luz (escala definida por el grupo)
	MOVLW B'00000001'
	MOVWF PORTB
	GOTO  LEERD
	;Mostrar el primer inciso
MOSTRAR2
;Al presionar la tecla cambiar� y deber� mostrar el n�mero del dispositivo con la mayor
;cantidad de luz.
	MOVLW B'00000010'
	MOVWF PORTB
	GOTO  LEERD
	;Mostrar el segundo inciso
MOSTRAR3
;Al presionar la tecla cambiar� y deber� mostrar el n�mero del dispositivo con la menor
;cantidad de luz.
	MOVLW B'00000100'
	MOVWF PORTB
	GOTO  LEERD
	;Mostrar el tercer inciso
MOSTRAR4
;Al presionar la tecla cambiar� y mostrar� cu�l es su n�mero de dispositivo
	MOVLW B'00001000'
	MOVWF PORTB
	;Mostrar el quinto inciso
	MOVLW B'00000000' 
	MOVWF Contador ;resetea el contador para empezar de nuevo
	GOTO  LEERD
	;Mostrar el cuarto inciso
