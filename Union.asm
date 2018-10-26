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

;------------------------------ VARIABLES DISPLAY --------------------------------------
DATO_DISPLAY EQU 0X2E

;------------------------------Variables Foto Resistencia
ADC EQU 0x2F
CON EQU 0X30
CON2 EQU 0X31
CON3 EQU 0X32
MAYOR_LUZR EQU 0x33
MENOR_LUZR EQU 0x34
CATEGORIA EQU 0X35
;------------------------------Comparacion Variables---------
Mayor_Encontrado EQU 0x36
Menor_Encontrado EQU 0x37
ENTRADA_Comp	EQU 0X38
ContMotorX	EQU 0X39

RegresarReiniciarX	EQU 0x3A
RegresarReiniciarY	Equ 0x3B
ContMotorY	Equ 0x3C
INICIO
;Inicio del programa ASIGNACIONES VARIABLES
	ORG	0X00

;------------------------CONFIGURACIONES PUERTOS --------------------------------------
;------------------------------ PUERTO A y E JEFF --------------------------------------
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
	bcf STATUS,RP0 ;Ir banco 0
	bcf STATUS,RP1

;------------------------------ PUERTO A y E --------------------------------------
	MOVLW b'00000000'
	MOVWF ContadorBTN
	MOVWF DATO_DISPLAY
	

;----Desactive estas configuraiones para poder ver lo de JEFF
	;BSF     STATUS,RP0
    ;BCF     STATUS,RP1
    ;MOVLW   D'14'
    ;MOVWF   ADCON1
	;MOVLW	B'111'
    ;MOVWF   TRISE
    ;BCF     STATUS,RP0
    ;BCF     STATUS,RP1

    	MOVLW   D'7'
    	MOVWF   NumGrupo
;------------------------------ PUERTO B --------------------------------------
	BSF STATUS, 5 ;PONE 1 EN STATUS BIT 5 PARA MOVERNOS AL BANCO 1
	CLRF TRISB; PONE EN 0 TRIS B Y LA BANDERA Z PONE SALIDA B 
	CLRF TRISC; HABILITA EL PUERTO C COMO SALIDA

	CLRW; LIMPIAR W 
	BCF STATUS, 5; PONE UN 0 EN BIT 5 Y NOS MOVEMOS AL BANCO 0 

;------------------------------ PUERTO C --------------------------------------
	;MOVLW B'11111111'
	;MOVWF DATO_DISPLAY
	MOVLW B'11111111'
	MOVWF PORTC

;--------------Configuracion de Mayores y menores

;PRUEBA para regresar el motor al mayor de luz  ELIMINAR
	;MOVLW	1 ; Moviendo a w El numero de iteraciones que vaya
	;MOVWF	IrMayorXIteracion 
	;MOVLW	45; Moviendo a W el numero de pasos que vaya en Y
	;MOVWF	IrMayorPasosY 

	GOTO	BTN_Inicio ;mueve el ip al punto de la etiqueta

;--------------------------MENU PROGRAMA-------------------------------
MENU 
	CAll	SeteoVariables
	CALL	LOOP_GENERAL ; Mover Motores y buscar mayor luz 
	
	MOVF	IrMayorXIteracion,W
	MOVWF	RegresarReiniciarX
	MOVF	IrMayorPasosY,W
	MOVWF	RegresarReiniciarY

	CALL	IrMayorLuz ;Moverme a Buscar LUz
	GOTO	LEER_E_BTN
	;GOTO FotoResistencia ;Para Graduar Foto Resistencia 
	GOTO	SALIR	

SeteoVariables
	MOVLW	16
	MOVWF	NumeroIteracionesX
	MOVLW	D'0'
	MOVWF	Mayor_Encontrado
	MOVLW	D'9'
	MOVWF	Menor_Encontrado
	MOVLW	B'00000000'
	MOVWF	PORTB
	MOVLW	D'0'
	MOVWF	ContMotorX
	MOVWF	IrMayorXIteracion
	MOVWF	IrMayorPasosY
	Return
;------------------------------ MOTORES INICIO --------------------------------------
LOOP_GENERAL
	MOVLW	32			;32*16 =512
	MOVWF	PasosX
	MOVWF	PasosRegresoX
	CALL	MOVER_X
	MOVLW	128
	MOVWF	PasosY
	MOVWF	PasosRegresoY
	INCF	ContMotorX,1
	CALL	CORRIDAY
	MOVLW	0
	MOVWF	ContMotorY
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
	INCF	ContMotorY,1
	CALL	BuscarYMarcarFoto
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
 	;MOVLW	B'00000000'
	;MOVWF	PORTB
	;RETLW	B'00000000'
	;Call	IrMayorLuz


IrMayorLuz
	MOVLW	32
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

ReiniciarTOTALX
	MOVLW	32
	MOVWF	PasosRegresoX
	CALL	REGRESOX
	DECFSZ	RegresarReiniciarX, 1
	GOTO	ReiniciarTOTALX
	;GOTO	FIN
	RETLW	B'00000000'
ReiniciarTOTALY
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
	DECFSZ	RegresarReiniciarY ,1
	GOTO	ReiniciarTOTALY
	RETLW	B'00000000'
;------------------------------ BOTON E 0 INICIAL -----------------------------------------
BTN_Inicio
	MOVF PORTE, W ;Movemos lo de PUERTO E hacia W
	MOVWF DatoEnE ;Movemos la variable hacia dato en E
	MOVLW B'001' ; MOVEMOS A W EL 0 BIT de E  
	SUBWF DatoEnE,W ;VA A RESTARLE AL DATO E LO QUE ESTA EN W
	CALL	Llamada16Delays
	CALL	Llamada16Delays
	BTFSC STATUS, Z ; VERIFICA QUE EL STATUS DE LA OPERACION SEA 0 
	goto	MENU
	goto	BTN_Inicio
LEER_E_BTN
	MOVF PORTE, W ;Movemos lo de PUERTO E hacia W
	MOVWF DatoEnE ;Movemos la variable hacia dato en E
	MOVLW B'001' ; MOVEMOS A W EL 0 BIT de E  
	SUBWF DatoEnE,W ;VA A RESTARLE AL DATO E LO QUE ESTA EN W
	CALL	Llamada16Delays
	CALL	Llamada16Delays
	BTFSC STATUS, Z ; VERIFICA QUE EL STATUS DE LA OPERACION SEA 0 
	GOTO  CONTAR ; SI LA OPERACION ES 0 SE VA A UN CONTAR

	MOVLW B'100'
	SUBWF DatoEnE,w
	BTFSC STATUS, Z ; VERIFICA QUE EL STATUS DE LA OPERACION SEA 0 
	GOTO  EmpezarDeNuevo ; SI LA OPERACION ES 0 SE VA A UN CONTAR


	GOTO  LEER_E_BTN ;REGRESA LOOP LEER

EmpezarDeNuevo
	CAll	ReiniciarTOTALY
	Call	ReiniciarTOTALX
	GOTO	BTN_Inicio	

CONTAR
	INCF  ContadorBTN, 0 ;incrementa e ContadorBTN en 1
	MOVWF ContadorBTN
	MOVLW b'00000001'
	SUBWF ContadorBTN,W
	BTFSC STATUS, Z
	GOTO  BTN1

	MOVLW b'00000010'
	SUBWF ContadorBTN,W
	BTFSC STATUS, Z
	GOTO  BTN2

	MOVLW b'00000011'
	SUBWF ContadorBTN,W
	BTFSC STATUS, Z
	GOTO  BTN3

	MOVLW b'00000100'
	SUBWF ContadorBTN, 0
	BTFSC STATUS, Z
	GOTO  BTN4

BTN1
;Al iniciar, mostrar cu�nto es el �ndice de luz (escala definida por el grupo)
	;MOVLW B'00000001'
	;MOVWF PORTB

	MOVLW D'0'
	MOVWF DATO_DISPLAY
	CALL  COMP_DISPLAY
	CALL	Llamada16Delays
	CALL	Llamada16Delays

	MOVLW D'1'
	MOVWF DATO_DISPLAY
	CALL  COMP_DISPLAY
	CALL	Llamada16Delays
	CALL	Llamada16Delays

	MOVLW D'2'
	MOVWF DATO_DISPLAY
	CALL  COMP_DISPLAY
	CALL	Llamada16Delays
	CALL	Llamada16Delays

	MOVLW D'3'
	MOVWF DATO_DISPLAY
	CALL  COMP_DISPLAY
	CALL	Llamada16Delays
	CALL	Llamada16Delays

	MOVLW D'4'
	MOVWF DATO_DISPLAY
	CALL  COMP_DISPLAY
	CALL	Llamada16Delays
	CALL	Llamada16Delays

	MOVLW D'5'
	MOVWF DATO_DISPLAY
	CALL  COMP_DISPLAY
	CALL	Llamada16Delays
	CALL	Llamada16Delays

	MOVLW D'6'
	MOVWF DATO_DISPLAY
	CALL  COMP_DISPLAY
	CALL	Llamada16Delays
	CALL	Llamada16Delays

	MOVLW D'7'
	MOVWF DATO_DISPLAY
	CALL  COMP_DISPLAY
	CALL	Llamada16Delays
	CALL	Llamada16Delays

	MOVLW D'8'
	MOVWF DATO_DISPLAY
	CALL  COMP_DISPLAY
	CALL	Llamada16Delays
	CALL	Llamada16Delays

	MOVLW D'9'
	MOVWF DATO_DISPLAY
	CALL  COMP_DISPLAY
	CALL	Llamada16Delays
	CALL	Llamada16Delays

	GOTO  LEER_E_BTN
	;Mostrar el primer inciso
BTN2
;Al presionar la tecla cambiar� y deber� mostrar el n�mero del dispositivo con la mayor
;cantidad de luz.
	;MOVLW B'00000010'
	;MOVWF PORTB
	
	MOVLW D'2'
	MOVWF DATO_DISPLAY

	CALL  COMP_DISPLAY

	GOTO  LEER_E_BTN
	;Mostrar el segundo inciso
BTN3
;Al presionar la tecla cambiar� y deber� mostrar el n�mero del dispositivo con la menor
;cantidad de luz.
	;MOVLW B'00000100'
	;MOVWF PORTB

	MOVLW D'3'
	MOVWF DATO_DISPLAY
	CALL  COMP_DISPLAY

	GOTO  LEER_E_BTN
	;Mostrar el tercer inciso
BTN4       ;Al presionar la tecla cambiar� y mostrar� cu�l es su n�mero de dispositivo
	;MOVLW B'00001000'
	;MOVWF PORTB

	MOVLW B'00000000' 
	MOVWF ContadorBTN ;resetea el ContadorBTN para empezar de nuevo

	MOVLW D'4'
	MOVWF DATO_DISPLAY
	CALL  COMP_DISPLAY
	GOTO  LEER_E_BTN


;------------------------------ DISPLAY  -----------------------------------------

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
	
	;MOVLW	B'00000000'
	;MOVWF	PORTB
	GOTO	LEER_E_BTN

MOSTRAR0
	MOVLW B'11000000' ; EN BINARIO PONEMOS 0 LOS NECESARIOS PARA PREDER EL DISPLAY EN 0
	MOVWF PORTC	;MOVEMOS LOS BINARIOS A PORT B 
	RETLW	B'00000000'

MOSTRAR1
	MOVLW B'11111001' ; EN BINARIO PONEMOS 1 LOS NECESARIOS PARA PREDER EL DISPLAY EN 0
	MOVWF PORTC	;MOVEMOS LOS BINARIOS A PORT B 
	RETLW	B'00000000'

MOSTRAR2
	MOVLW B'10100100' ; EN BINARIO PONEMOS 2 LOS NECESARIOS PARA PREDER EL DISPLAY EN 0
	MOVWF PORTC	;MOVEMOS LOS BINARIOS A PORT B 
	RETLW	B'00000000'

MOSTRAR3
	MOVLW B'10110000' ; EN BINARIO PONEMOS 3 LOS NECESARIOS PARA PREDER EL DISPLAY EN 0
	MOVWF PORTC	;MOVEMOS LOS BINARIOS A PORT B 
	RETLW	B'00000000'
		
MOSTRAR4
	MOVLW B'10011001' ; EN BINARIO PONEMOS 4 LOS NECESARIOS PARA PREDER EL DISPLAY EN 0
	MOVWF PORTC	;MOVEMOS LOS BINARIOS A PORT B 
	RETLW	B'00000000'

MOSTRAR5
	MOVLW B'10010010' ; EN BINARIO PONEMOS 5 LOS NECESARIOS PARA PREDER EL DISPLAY EN 0
	MOVWF PORTC	;MOVEMOS LOS BINARIOS A PORT B 
	RETLW	B'00000000'

MOSTRAR6
	MOVLW B'10000010' ; EN BINARIO PONEMOS 6 LOS NECESARIOS PARA PREDER EL DISPLAY EN 0
	MOVWF PORTC	;MOVEMOS LOS BINARIOS A PORT B 
	RETLW	B'00000000'

MOSTRAR7
	MOVLW B'11111000' ; EN BINARIO PONEMOS 7 LOS NECESARIOS PARA PREDER EL DISPLAY EN 0
	MOVWF PORTC	;MOVEMOS LOS BINARIOS A PORT B 
	RETLW	B'00000000'

MOSTRAR8
	MOVLW B'10000000' ; EN BINARIO PONEMOS 8 LOS NECESARIOS PARA PREDER EL DISPLAY EN 0
	MOVWF PORTC	;MOVEMOS LOS BINARIOS A PORT B 
	RETLW	B'00000000'

MOSTRAR9
	MOVLW B'10011000' ; EN BINARIO PONEMOS 9 LOS NECESARIOS PARA PREDER EL DISPLAY EN 0
	MOVWF PORTC	;MOVEMOS LOS BINARIOS A PORT B 
	RETLW	B'00000000'

;------------------------------FOTO RESISTENCIA  -----------------------------------------
FotoResistencia
	CALL _bucle
	MOVF	CATEGORIA,W
	MOVWF DATO_DISPLAY
	CALL  COMP_DISPLAY
	GOTO FotoResistencia

BuscarYMarcarFoto
	Call _bucle
	MovF categoria,W
	MOVWF ENTRADA_Comp
	Call Comparacion_nums
	RETURN

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
	;movlw D'32' ;Comparamos el valor del ADC para saber si es menor que 128
	;subwf ADC,W
	;btfss STATUS,C ;Es mayor a 128?
	;goto _desactivar ;No, desactivar RB7
	;bsf PORTC,7 ;Si, RB7 = 1 logico
	;goto _bucle ;Ir bucle
;_desactivar
	;bcf PORTB,7 ;RB7 = 0 logico
	;goto _bucle ;Ir bucle
	
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
	;MOVLW	B'00000001'
	;MOVWF	PORTD
	RETURN

EntradaMenor
	MOVF	CATEGORIA,W
	MOVWF	MENOR_LUZR
	;MOVLW	B'00000010'
	;MOVWF	PORTD
	RETURN
;--------------------------Compracion numeros----------------------------------------------
Comparacion_nums	
	MOVF	ENTRADA_Comp,W
	SUBWF	Menor_Encontrado,W	
	BTFSC	STATUS,C
	CALL	EntradaMenor_nums

	MOVF	ENTRADA_Comp,W
	SUBWF	Mayor_Encontrado,W
	BTFSS	STATUS,C
	CALL 	EntradaMayor_nums

	RETURN

EntradaMayor_nums
	MOVF	ENTRADA_Comp,W
	MOVWF	Mayor_Encontrado
	;Moviendo la Iteracion X y Moviento en y
	MOVF 	ContMotorX,W
	MOVWF	IrMayorXIteracion
	;INCF	IrMayorXIteracion,1

	MOVF 	ContMotorY,W
	MOVWF	IrMayorPasosY

	;MOVLW	B'00000001'
	;MOVWF	PORTD
	RETURN

EntradaMenor_nums
	MOVF	ENTRADA_Comp,W
	MOVWF	Menor_Encontrado
	;MOVLW	B'00000010'
	;MOVWF	PORTD
	RETURN

;---------------------------------------Procedimientos Varios ---------------------------------
Llamada16Delays
	CALL	DelayOneSecond
	CALL	DelayOneSecond	
	CALL	DelayOneSecond
	CALL	DelayOneSecond
	CALL	DelayOneSecond
	CALL	DelayOneSecond	
	CALL	DelayOneSecond
	CALL	DelayOneSecond
	CALL	DelayOneSecond
	CALL	DelayOneSecond	
	CALL	DelayOneSecond
	CALL	DelayOneSecond
	CALL	DelayOneSecond
	CALL	DelayOneSecond	
	CALL	DelayOneSecond
	CALL	DelayOneSecond
	RETURN

;--------------------------------------REINICIAR-------------------------------------------

