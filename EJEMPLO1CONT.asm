;configuracion 
;status 
	ORG 0x00 ;se elige en que posicion de memoria empezaremos 
	GOTO START
;codigo
START
	BSF Status,5 
	CLRF trisb ;
	BCF STATUS, PORTB  ;bcf lo pone en 0
	BCF STATUS, 5
	MOVLW 0x00 ;se asigna la literal a w (0x00)
	movwf PORTB ;muevo w a portB 
	GOTO inc 
inc 
	ADDLW 0x01 ; sume a w la literal (0x01)
	MOVWF PORTB ; se mueve lo que tiene w a f (portB)
	GOTO INC 
END