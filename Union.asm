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
;-----------------------------Variables Comunicacion-----------
DATO_Comunicacion	EQU 0X3D
CONR	EQU 0X3E
CONE	EQU 0X3F
MAYG	EQU 0X40 ; grupo mayor
MAYV	EQU 0X41 ; valor grupo mayor
MENG	EQU 0X42 ; grupo menor
MENV	EQU 0X43 ; valor grupo menor
MAYBG	EQU 0X44 ; grupo mayor backup
MAYBV	EQU 0X45 ; valor grupo mayor backup
MENBG	EQU 0X46 ; grupo menor backup
MENBV	EQU 0X47 ; valor grupo menor backup
d1	EQU 0X48
d2	EQU 0X49
d3	EQU 0X4A
Prueba_D	EQU 0x4B




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
	BCF		TRISD,4
	BCF		TRISD,5	
	BCF		TRISD,6	
	BCF		TRISD,7

	BSF		TRISD,0
	BSF		TRISD,1
	BSF		TRISD,2
	BSF		TRISD,3

	BSF		TRISA,5
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

	;BCF		TRISD,4
	;BCF		TRISD,5	
	;BCF		TRISD,6	
	;BCF		TRISD,7

	;BSF		TRISD,0
	;BSF		TRISD,1
	;BSF		TRISD,2
	;BSF		TRISD,3

	;BSF		TRISA,5

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
;--------------------Configuracion de Comunicacion----------------
	; siempre debemos modificar el registro status antes de utilizar los puertos
	;BSF	STATUS, 5 
	;BSF	TRISB, 0 ; env�a datos PORT E ,2
	;MOVLW	B'00000000'
	;MOVWF	TRISD
	
	;BCF		TRISD,0
	;BCF		TRISD,1	
	;BCF		TRISD,2	
	;BCF		TRISD,3
	;BSF		TRISD,4
	;BSF		TRISD,5
	;BSF		TRISD,6
	;BSF		TRISD,7

	;BCF	TRISB, 1
	;BCF	TRISB, 2
	;BCF	TRISB, 3
	;BCF	TRISB, 4
	;BSF	TRISC, 0 ; BIT 0 recibir
	;BSF	TRISC, 1 ; BIT 1 recibir
	;BSF	TRISC, 2 ; BIT 2 recibir
	;BSF	TRISC, 3 ; BIT 3 recibir
	;BSF	TRISD, 0 ; identifica que tiene que recibir datos PORTA, 5
	;BCF 	STATUS, RP0
	MOVLW   B'00000001'
	MOVWF	CONE
	MOVWF	CONR
	;------------Datos Prueba
	;MOVLW	B'00000001'
	;MOVWF	MAYG
	;MOVWF	MENG
	;MOVLW	B'00000101'
	;MOVWF	MAYV
	;MOVWF	MENV
	
	movlw	B'00000000'
	MOVWF	PORTD
	
	;Goto	PruebaA	
	GOTO	BTN_Inicio ;mueve el ip al punto de la etiqueta <$%^&*&^%$#%^&*&^%$#%^&^%$#$%^&
	
	;MOVLW D'1'
	;MOVWF	MAYG
	;MOVLW D'1'
	;MOVWF	MENG

	;MOVLW D'9'
	;MOVWF	Mayor_Encontrado

	;MOVF	Mayor_Encontrado,W
	;MOVWF	MAYV
	;MOVF	Mayor_Encontrado,W
	;MOVWF	MENV
	;GOTO	LEER_E_BTN



;PruebaA
;	BTFSC	PORTA, 5
;	GOTO	PruebaB
;	GOTO	PruebaA

;PruebaB
;	MOVLW B'00001111'
;	MOVWF	PORTB
;
;	MOVF PORTD, W ;Movemos lo de PUERTO E hacia W
;	MOVWF DatoEnE ;Movemos la variable hacia dato en E
;	MOVLW B'00001111'
;	SUBWF DatoEnE,w
;	BTFSC STATUS, Z ; VERIFICA QUE EL STATUS DE LA OPERACION SEA 0 
;	GOTO  PruebaC ; SI LA OPERACION ES 0 SE VA A UN CONTAR
;	GOTO	PruebaB

;PruebaC
;	MOVLW B'11110000'
;	MOVWF	PORTB
;	Goto	PruebaA



;--------------------------MENU PROGRAMA-------------------------------
MENU 
	CAll	SeteoVariables
	CALL	LOOP_GENERAL ; Mover Motores y buscar mayor luz 
	
	MOVF	IrMayorXIteracion,W
	MOVWF	RegresarReiniciarX
	MOVF	IrMayorPasosY,W
	MOVWF	RegresarReiniciarY

	CALL	IrMayorLuz ;Moverme a Buscar LUz
	
	MOVLW	D'1'
	MOVWF	MAYG
	MOVLW	D'1'
	MOVWF	MENG

	MOVF	Mayor_Encontrado,W
	MOVWF	MAYV
	MOVF	Mayor_Encontrado,W
	MOVWF	MENV

	movlw	B'00000000'
	MOVWF	PORTB


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
	goto	MENU  ;<----------------------<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
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

	;MOVLW B'010'
	;SUBWF DatoEnE,w
	;BTFSC STATUS, Z ; VERIFICA QUE EL STATUS DE LA OPERACION SEA 0 
	;CALL  MENU_Comunicacion ; SI LA OPERACION ES 0 SE VA A UN CONTAR

	;CALL	DELAY
	BTFSC   PORTE, 1 ; si el bit de enviar enta encendido va a enviar datos
	CALL	ENVIARDEC
	;CALL	DELAY

	BTFSC	PORTA, 5
	CALL	RECIBIRDEC

	;CALL	DELAY


	;MENU_ComunicacionB
	;
	;CALL	DELAY
	;MOVLW B'010'
	;SUBWF DatoEnE,w
	;BTFSC STATUS, Z ; VERIFICA QUE EL STATUS DE LA OPERACION SEA 0 
	;CALL	ENVIARDEC
	;CALL	DELAY
	;BTFSC	PORTA, 5
	;CALL	RECIBIRDEC

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

	;MOVLW D'0'
	;MOVWF DATO_DISPLAY
	;CALL  COMP_DISPLAY
	;CALL	Llamada16Delays
	;CALL	Llamada16Delays

	MOVF 	Mayor_Encontrado,w
	MOVWF 	DATO_DISPLAY
	CALL	COMP_DISPLAY
	CALL	Llamada16Delays
	CAll	Llamada16Delays

	GOTO  LEER_E_BTN
	;Mostrar el primer inciso
BTN2
;Al presionar la tecla cambiar� y deber� mostrar el n�mero del dispositivo con la mayor
;cantidad de luz.
	;MOVLW B'00000010'
	;MOVWF PORTB
	
	;MOVLW D'2'
	MOVF	MAYG,W
	MOVWF DATO_DISPLAY
	CALL  COMP_DISPLAY
	CALL	Llamada16Delays
	CAll	Llamada16Delays

	GOTO  LEER_E_BTN
	;Mostrar el segundo inciso
BTN3
;Al presionar la tecla cambiar� y deber� mostrar el n�mero del dispositivo con la menor
;cantidad de luz.
	;MOVLW B'00000100'
	;MOVWF PORTB

	;MOVLW D'3'
	MOVF	MENG,W
	MOVWF DATO_DISPLAY
	CALL  COMP_DISPLAY
	CALL	Llamada16Delays
	CAll	Llamada16Delays

	GOTO  LEER_E_BTN
	;Mostrar el tercer inciso
BTN4       ;Al presionar la tecla cambiar� y mostrar� cu�l es su n�mero de dispositivo
	;MOVLW B'00001000'
	;MOVWF PORTB

	MOVLW B'00000000' 
	MOVWF ContadorBTN ;resetea el ContadorBTN para empezar de nuevo

	MOVLW D'1'
	MOVWF DATO_DISPLAY
	CALL  COMP_DISPLAY
	CALL	Llamada16Delays
	CAll	Llamada16Delays
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
	MOVWF DATO_DISPLAY
	CALL  COMP_DISPLAY
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

;-------------------------------CONFIGURACION COMUNICACION----------------------------------
MENU_Comunicacion
	CALL	DELAY
	BTFSC   PORTE, 1 ; si el bit de enviar enta encendido va a enviar datos
	CALL	ENVIARDEC
	CALL	DELAY
	RETURN

MENU_ComunicacionB

	BTFSC	PORTA, 5
	CALL	RECIBIRDEC
	CALL	DELAY
	Return

ENVIARDEC ; Decide que enviar encicladamente
	CALL	DELAY
	MOVLW	B'00000001'
	SUBWF	CONE, 0
	BTFSC	STATUS, Z
	CALL	ENVIARGM ; enviar grupo mayor
	CALL	DELAY
	MOVLW	B'00000010'
	SUBWF	CONE, 0
	BTFSC	STATUS, Z
	CALL	ENVIARVM ; enviar valor mayor
	CALL	DELAY
	MOVLW	B'00000011'
	SUBWF	CONE, 0
	BTFSC	STATUS, Z
	CALL	ENVIARGMM ; enviar grupo menor
	CALL	DELAY
	MOVLW	B'00000100'
	SUBWF	CONE, 0
	BTFSC	STATUS, Z
	CALL	ENVIARVMM ; enviar valor menor
	CALL	DELAY
	MOVLW	B'00000101'
	SUBWF	CONE, 0
	BTFSC	STATUS, Z
	CALL	FINENV; hacer comparacion	
	INCF	CONE, 1	
	RETURN

SETBITS
	BTFSC	DATO_Comunicacion, 0
	GOTO	SET11
	GOTO	SET10
SETBITS1
	BTFSC	DATO_Comunicacion, 1
	GOTO	SET21
	GOTO	SET20
SETBITS2
	BTFSC	DATO_Comunicacion, 2
	GOTO	SET31
	GOTO	SET30
SETBITS3
	BTFSC	DATO_Comunicacion, 3
	GOTO	SET41
	GOTO	SET40
ENDSET
	RETURN	

SET11
	BSF	PORTD, 4
	GOTO	SETBITS1
SET10
	BCF	PORTD, 4
	GOTO	SETBITS1
	
SET21
	BSF	PORTD, 5
	GOTO	SETBITS2
SET20
	BCF	PORTD, 5
	GOTO	SETBITS2
	
SET31
	BSF	PORTD, 6
	GOTO	SETBITS3
SET30
	BCF	PORTD, 6
	GOTO	SETBITS3
	
SET41
	BSF	PORTD, 7
	GOTO	ENDSET
SET40
	BCF	PORTD, 7
	GOTO	ENDSET
	
ENVIARGM
	MOVF	MAYG, W
	MOVWF 	DATO_Comunicacion
	CALL	SETBITS
	BTFSC	PORTE, 1
	GOTO	ENVIARGM 
	RETURN
	
ENVIARVM
	MOVF	MAYV, W
	MOVWF 	DATO_Comunicacion
	CALL	SETBITS	
	BTFSC	PORTE, 1
	GOTO	ENVIARVM 
	RETURN
	
ENVIARGMM
	MOVF	MENG, W
	MOVWF 	DATO_Comunicacion
	CALL	SETBITS	
	BTFSC	PORTE, 1
	GOTO	ENVIARGMM 
	RETURN
	
ENVIARVMM
	MOVF	MENV, W
	MOVWF 	DATO_Comunicacion
	CALL	SETBITS	
	BTFSC	PORTE, 1
	GOTO	ENVIARVMM 
	RETURN

RECIBIRDEC ; recibe encicladamente
	CALL	DELAY
	MOVLW	B'00000001'
	SUBWF	CONR, 0
	BTFSC	STATUS, Z
	CALL	RECIBIRGM ; enviar grupo mayor
	CALL	DELAY
	MOVLW	B'00000010'
	SUBWF	CONR, 0
	BTFSC	STATUS, Z
	CALL	RECIBIRVM ; enviar valor mayor
	CALL	DELAY
	MOVLW	B'00000011'
	SUBWF	CONR, 0
	BTFSC	STATUS, Z
	CALL	RECIBIRGMM ; enviar grupo menor
	CALL	DELAY
	MOVLW	B'00000100'
	SUBWF	CONR, 0
	BTFSC	STATUS, Z
	CALL	RECIBIRVMM ; enviar valor menor	
	CALL	DELAY
	MOVLW	B'00000101'
	SUBWF	CONR, 0
	BTFSC	STATUS, Z
	CALL	FINREC; hacer comparacion	
	INCF	CONR, 1			
	RETURN
	
FINREC
	MOVLW	B'00000000'
	MOVWF   CONR
	CALL	COMPAREMAYORG
	CALL	COMPAREMENORG
	BTFSC	PORTA, 5
	GOTO	FINREC 
	RETURN
	
FINENV
	MOVLW	B'00000000'
	MOVWF   CONE
	BTFSC	PORTE, 1
	GOTO	FINENV
	RETURN
	
SET11R
	BSF	DATO_Comunicacion, 0
	GOTO	SETBITS1R
SET10R
	BCF	DATO_Comunicacion, 0
	GOTO	SETBITS1R
	
SET21R
	BSF	DATO_Comunicacion, 1
	GOTO	SETBITS2R
SET20R
	BCF	DATO_Comunicacion, 1
	GOTO	SETBITS2R
	
SET31R
	BSF	DATO_Comunicacion, 2
	GOTO	SETBITS3R
SET30R
	BCF	DATO_Comunicacion, 2
	GOTO	SETBITS3R
	
SET41R
	BSF	DATO_Comunicacion, 3
	GOTO	ENDSETR
SET40R
	BCF	DATO_Comunicacion, 3
	GOTO	ENDSETR

SETBITSR
	BTFSC	PORTD, 0
	GOTO	SET11R
	GOTO	SET10R
SETBITS1R
	BTFSC	PORTD, 1
	GOTO	SET21R
	GOTO	SET20R
SETBITS2R
	BTFSC	PORTD, 2
	GOTO	SET31R
	GOTO	SET30R
SETBITS3R
	BTFSC	PORTD, 3
	GOTO	SET41R
	GOTO	SET40R
ENDSETR
	RETURN	

	
RECIBIRGM
	CALL	SETBITSR
	MOVF	DATO_Comunicacion, W
	MOVWF	MAYBG
	BTFSC	PORTA, 5
	GOTO	RECIBIRGM 
	RETURN	
	
RECIBIRVM
	CALL	SETBITSR
	MOVF	DATO_Comunicacion, W
	MOVWF	MAYBV
	BTFSC	PORTA, 5
	GOTO	RECIBIRVM 
	RETURN

RECIBIRGMM
	CALL	SETBITSR
	MOVF	DATO_Comunicacion, W
	MOVWF	MENBG
	BTFSC	PORTA, 5
	GOTO	RECIBIRGMM 
	RETURN	

RECIBIRVMM
	CALL	SETBITSR
	MOVF	DATO_Comunicacion, W
	MOVWF	MENBV
	BTFSC	PORTA, 5
	GOTO	RECIBIRVMM 
	RETURN

COMPAREMAYORG 
	MOVF  MAYV, W
	SUBWF MAYBV, W
	BTFSS STATUS, C       
	GOTO  NOCHANGEMAY
	GOTO  CHANGEMAY	                        

CHANGEMAY
	MOVF  MAYBG, W 
        MOVWF MAYG
        MOVF  MAYBV, W
        MOVWF MAYV
	RETURN

NOCHANGEMAY
	RETURN
	
COMPAREMENORG 
	MOVF  MENV, W
	SUBWF MENBV, W
	BTFSS STATUS, C  
	GOTO  CHANGEMEN     
	GOTO  NOCHANGEMEN	                        

CHANGEMEN
	MOVF  MENBG, W 
        MOVWF MENG
        MOVF  MENBV, W
        MOVWF MENV
	RETURN

NOCHANGEMEN
	RETURN
	
	
DELAY
	movlw	0x87
	movwf	d1
	movlw	0x14
	movwf	d2
Delay_0
	decfsz	d1, f
	goto	$+2
	decfsz	d2, f
	goto	Delay_0

			;2 cycles
	goto	$+1
	RETURN