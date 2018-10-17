Contador EQU 0X21
DatoEnC  EQU 0x22
INICIO
	ORG 0X00
	GOTO START
START
;CONFIGURACION DEL BOTON EN EL BIT 5 EN EL PUERTO C
	BSF STATUS, 5 ;PONE 1 EN STATUS BIT 5 PARA MOVERNOS AL BANCO 1
	CLRF TRISB; PONE EN 0 TRIS B Y LA BANDERA Z
	CLRF TRISD
	MOVLW B'00100000' ; LA ENTRADA 5 EN PUERTO C HABILITADA
	MOVWF TRISC; HABILITAMOS EL BIT 5 EN C 
	CLRW; LIMPIAR W 
	BCF STATUS, 5; PONE UN 0 EN BIT 5 Y NOS MOVEMOS AL BANCO 0 
	MOVLW b'00000000'
	MOVWF Contador
	GOTO LEERC

LEERC;LEEMOS PUERTO C
	MOVF PORTC, W ; MOVEMOS LA ENTRADA DEL PUERTO C HACIA W 
	MOVWF DatoEnC ; movemos la variable hacia dato en c
	MOVLW B'00100000' ;MOVEMOS A W EL 5 BIT  
	SUBWF DatoEnC,W ;VA A RESTARLE AL DATO LO QUE ESTA EN W
	BTFSC STATUS, Z ; VERIFICA QUE EL STATUS DE LA OPERACION SEA 0 
	GOTO  CONTAR ; SI LA OPERACION ES 0 SE VA A UN CONTAR
	GOTO  LEERC ;REGRESA LOOP LEER
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

	MOVLW b'00000001'
	SUBWF Contador,W
	BTFSC STATUS, Z
	GOTO  LEERC

	GOTO  MOSTRAR5
MOSTRAR1
;Al iniciar, mostrar cuánto es el índice de luz (escala definida por el grupo)
	MOVLW B'00000001'
	MOVWF PORTD
	GOTO  LEERC
	;Mostrar el primer inciso
MOSTRAR2
;Al presionar la tecla cambiará y deberá mostrar el número del dispositivo con la mayor
;cantidad de luz.
	MOVLW B'00000010'
	MOVWF PORTD
	GOTO  LEERC
	;Mostrar el segundo inciso
MOSTRAR3
;Al presionar la tecla cambiará y deberá mostrar el número del dispositivo con la menor
;cantidad de luz.
	MOVLW B'00000100'
	MOVWF PORTD
	GOTO  LEERC
	;Mostrar el tercer inciso
MOSTRAR4
;Al presionar la tecla cambiará y mostrará cuál es su número de dispositivo
	MOVLW B'00001000'
	MOVWF PORTD
	GOTO  LEERC
	;Mostrar el cuarto inciso
MOSTRAR5
;Si se vuelve a presionar la tecla, cambiará al índice de luz
	MOVLW B'00010000'
	MOVWF PORTD
	;Mostrar el quinto inciso
	MOVLW B'00000000' 
	MOVWF Contador ;resetea el contador para empezar de nuevo
	GOTO  LEERC