CounterA EQU 0X24
CounterB EQU 0X25
CounterC EQU 0X26
Pasos	 EQU 0X27
INICIO
	ORG	0X00
	GOTO	START ;mueve el ip al punto de la etiqueta
START
	BSF	STATUS,	5
	CLRF	TRISB
	BCF	STATUS,	5
	MOVLW	B'00000001'
	MOVWF	Pasos
	GOTO	FULLCLK
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
	DECF	Paso
	BTFSS   Pasos
	GOTO	FULLCLK
DelayOneSecond
	movlw D'2'   ;D'6'
	movwf CounterC
	movlw D'2'  ;D'24'
	movwf CounterB
	movlw D'2' ;D'168'
	movwf CounterA
loop
	decfsz CounterA,1
	goto loop
	decfsz CounterB,1
	goto loop
	decfsz CounterC,1
	goto loop
	RETLW	b'00000000'
END