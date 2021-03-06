DATO_DISPLAY EQU 0X21; CREAMOS UNA VARIABLE EN BANCO 0 EN AREA DE MEMORIA DE PROPOSITO GENERAL
INICIO
	ORG 0X00
	GOTO START

START
;CONFIGURACION DE ENTRADAS EN C Y SALIDAS EN B
	BSF	STATUS,5 ; PONE UN 1 EN STATUS BIT 5, PARA MOVERNOS AL BANCO 1 
	CLRF	TRISB ; PONE EN 0 TRISB Y LA BANDERA Z
	MOVLW	B'00101111' ; PONEMOS EN BINARIO LAS ENTRADAS QUE QUEREMOS HABILITAR PIN 0 AL 3 ENTRADA DE DIGITOS Y PIN 5 MOSTRAR DIGITO
	MOVWF	TRISC ;MUEVE LO QUE TENGAMOS EN W HACIA TRISC PARA HABILITAR LAS ENTRADAS
	CLRW	;LIMPIAR W
	BCF	STATUS, 5 ; PONE UN 0 EN STATUS EN BIT 5 Y ESTO NOS MUEVE AL BANCO 0	

	GOTO 	LEER_DISPLAY;

LEER_DISPLAY
;LEMOS EL DATO_DISPLAY INGRESADO EN PUERTO C
	MOVF	PORTC, W ;MUEVE LA ENTRADA DEL PUERTO C HACIA W
	MOVWF	DATO_DISPLAY 	;MUEVE DE W A LA VARIABLE DATO_DISPLAY
	GOTO	COMP_DISPLAY 

COMP_DISPLAY
;COMPARACION BIT POR BIT 
	MOVLW	B'00000000' ;LE ENVIAMOS A W EL NUMERO 0 EN BINARIO EN 8 BITS
	SUBWF	DATO_DISPLAY,W 	;LE VAMOS A QUITAR A DATO_DISPLAY W (DATO_DISPLAY-W)=W
	BTFSC	STATUS,Z
	GOTO	MOSTRAR0

	MOVLW	B'00000001' ;LE ENVIAMOS A W EL NUMERO 1 EN BINARIO EN 8 BITS
	SUBWF	DATO_DISPLAY,W 	;LE VAMOS A QUITAR A DATO_DISPLAY W (DATO_DISPLAY-W)=W
	BTFSC	STATUS,Z
	GOTO	MOSTRAR1

	MOVLW	B'00000010' ;LE ENVIAMOS A W EL NUMERO 2 EN BINARIO EN 8 BITS
	SUBWF	DATO_DISPLAY,W 	;LE VAMOS A QUITAR A DATO_DISPLAY W (DATO_DISPLAY-W)=W
	BTFSC	STATUS,Z
	GOTO	MOSTRAR2
	
	MOVLW	B'00000011' ;LE ENVIAMOS A W EL NUMERO 3 EN BINARIO EN 8 BITS
	SUBWF	DATO_DISPLAY,W 	;LE VAMOS A QUITAR A DATO_DISPLAY W (DATO_DISPLAY-W)=W
	BTFSC	STATUS,Z
	GOTO	MOSTRAR3

	MOVLW	B'00000100' ;LE ENVIAMOS A W EL NUMERO 4 EN BINARIO EN 8 BITS
	SUBWF	DATO_DISPLAY,W 	;LE VAMOS A QUITAR A DATO_DISPLAY W (DATO_DISPLAY-W)=W
	BTFSC	STATUS,Z
	GOTO	MOSTRAR4

	MOVLW	B'00000101' ;LE ENVIAMOS A W EL NUMERO 5 EN BINARIO EN 8 BITS
	SUBWF	DATO_DISPLAY,W 	;LE VAMOS A QUITAR A DATO_DISPLAY W (DATO_DISPLAY-W)=W
	BTFSC	STATUS,Z
	GOTO	MOSTRAR5

	MOVLW	B'00000110' ;LE ENVIAMOS A W EL NUMERO 6 EN BINARIO EN 8 BITS
	SUBWF	DATO_DISPLAY,W 	;LE VAMOS A QUITAR A DATO_DISPLAY W (DATO_DISPLAY-W)=W
	BTFSC	STATUS,Z
	GOTO	MOSTRAR6

	MOVLW	B'00000111' ;LE ENVIAMOS A W EL NUMERO 7 EN BINARIO EN 8 BITS
	SUBWF	DATO_DISPLAY,W 	;LE VAMOS A QUITAR A DATO_DISPLAY W (DATO_DISPLAY-W)=W
	BTFSC	STATUS,Z
	GOTO	MOSTRAR7

	MOVLW	B'00001000' ;LE ENVIAMOS A W EL NUMERO 8 EN BINARIO EN 8 BITS
	SUBWF	DATO_DISPLAY,W 	;LE VAMOS A QUITAR A DATO_DISPLAY W (DATO_DISPLAY-W)=W
	BTFSC	STATUS,Z
	GOTO	MOSTRAR8

	MOVLW	B'00001001' ;LE ENVIAMOS A W EL NUMERO 9 EN BINARIO EN 8 BITS
	SUBWF	DATO_DISPLAY,W 	;LE VAMOS A QUITAR A DATO_DISPLAY W (DATO_DISPLAY-W)=W
	BTFSC	STATUS,Z
	GOTO	MOSTRAR9
	
	MOVLW	B'00000000'
	MOVWF	PORTB
	GOTO	LEER_DISPLAY

MOSTRAR0
	MOVLW B'00111111' ; EN BINARIO PONEMOS 0 LOS NECESARIOS PARA PREDER EL DISPLAY EN 0
	MOVWF PORTC	;MOVEMOS LOS BINARIOS A PORT B 
	GOTO LEER_DISPLAY

MOSTRAR1
	MOVLW B'00000110' ; EN BINARIO PONEMOS 1 LOS NECESARIOS PARA PREDER EL DISPLAY EN 0
	MOVWF PORTC	;MOVEMOS LOS BINARIOS A PORT B 
	GOTO LEER_DISPLAY

MOSTRAR2
	MOVLW B'01011011' ; EN BINARIO PONEMOS 2 LOS NECESARIOS PARA PREDER EL DISPLAY EN 0
	MOVWF PORTC	;MOVEMOS LOS BINARIOS A PORT B 
	GOTO LEER_DISPLAY

MOSTRAR3
	MOVLW B'01001111' ; EN BINARIO PONEMOS 3 LOS NECESARIOS PARA PREDER EL DISPLAY EN 0
	MOVWF PORTC	;MOVEMOS LOS BINARIOS A PORT B 
	GOTO LEER_DISPLAY
		
MOSTRAR4
	MOVLW B'01100110' ; EN BINARIO PONEMOS 4 LOS NECESARIOS PARA PREDER EL DISPLAY EN 0
	MOVWF PORTC	;MOVEMOS LOS BINARIOS A PORT B 
	GOTO LEER_DISPLAY

MOSTRAR5
	MOVLW B'01101101' ; EN BINARIO PONEMOS 5 LOS NECESARIOS PARA PREDER EL DISPLAY EN 0
	MOVWF PORTC	;MOVEMOS LOS BINARIOS A PORT B 
	GOTO LEER_DISPLAY

MOSTRAR6
	MOVLW B'01111101' ; EN BINARIO PONEMOS 6 LOS NECESARIOS PARA PREDER EL DISPLAY EN 0
	MOVWF PORTC	;MOVEMOS LOS BINARIOS A PORT B 
	GOTO LEER_DISPLAY

MOSTRAR7
	MOVLW B'00000111' ; EN BINARIO PONEMOS 7 LOS NECESARIOS PARA PREDER EL DISPLAY EN 0
	MOVWF PORTC	;MOVEMOS LOS BINARIOS A PORT B 
	GOTO LEER_DISPLAY

MOSTRAR8
	MOVLW B'01111111' ; EN BINARIO PONEMOS 8 LOS NECESARIOS PARA PREDER EL DISPLAY EN 0
	MOVWF PORTC	;MOVEMOS LOS BINARIOS A PORT B 
	GOTO LEER_DISPLAY

MOSTRAR9
	MOVLW B'01100111' ; EN BINARIO PONEMOS 9 LOS NECESARIOS PARA PREDER EL DISPLAY EN 0
	MOVWF PORTC	;MOVEMOS LOS BINARIOS A PORT B 
	GOTO LEER_DISPLAY