	.data 

#HAY ETIQUETAS QUE SE PUEDEN REDUCIR COLOCANDOLAS EN ARREGLOS 
#PUEDE PONERSE UN SOLO ALIGN AL FINAL DE CARGAR TODOS LOS .ASCIIZ O SE PUEDE ALINEAR CADA MENSAJE PARA QUE EMPIECEN PALABRAS DISTINTAS

Path:   	 .asciiz "PIEDRAS.txt"
SaltoLinea: 	 .asciiz "\n"
SaltosLinea: 	 .asciiz "\n\n\n\n\n"
Mensaje1:	 .asciiz "\nPor favor introduzca su nombre (debe tener un maximo de 20 caracteres):  "
MensajeLoadError:.ascii "Error al cargar el archivo. Por favor verifique que el archivo se encuentre en la ruta correcta."
MensajePuntos:   .asciiz "Puntajes: "
MensajeEquipo1:  .asciiz "Equipo 1: "
MensajeEquipo2:  .asciiz "    Equipo 2: "
MensajeTurno:    .asciiz "        Turno actual: "
SeleccionFicha:  .asciiz "\nPara seleccionar una ficha, enumerelas de izquierda a derecha (comenzando por 1) e ingrese el numero de la que desee jugar.\n"
SeleccionFicha2: .asciiz "(Si desea pasar el turno ingrese 0): "
MensajeTablero:  .asciiz "\nTablero\n"
FichaIncorrecta: .asciiz "\nLa ficha indicada no puede ser jugada, vuelva a intentarlo\n"

.align 2

ImpresionNumero: .space 4
NombreJ1: .space 20
NombreJ2: .space 20
NombreJ3: .space 20
NombreJ4: .space 20

Archivo: .space 140	#Se requieren de 5 bytes por ficha para leer las 28 fichas con el formato (1,2)
Fichas:  .space 56      #Para sacar las fichas del formato de entrada (sin "(", ")", ",")


Tablero: .space 336	#Para que cada ficha del tablero tenga una palabra para los dos numeros de la ficha y dos palabras para los
			#apuntadores a la siguiente ficha y a la anterior (esto para poder imprimir el tablero mas facil)
#FichasJ1:.space 4	#Para tener las fichas de cada jugador en un arreglo (cada ficha ocupa un byte). Cuando un jugador
			#juegue alguna ficha, esta se quita del arreglo colocando 7 o -1 en lugar del valor que estaba
InicioTablero: .space 4
FinTablero: .space 4

FichasJugadores: .space 32	#Cada jugador tendra dos apuntadores a sus fichas en el arreglo Fichas, de modo que no haya necesidad de crear
			#un arreglo con fichas para cada jugador, sino que cada jugador tiene 7 fichas. Jugador uno: (Fichas,Fichas+12)
			#Jugador dos: (Fichas+14,Fichas+26), J3: (Fichas+28,Fichas+40),J4 (Fichas+42,Fichas+54)


#FichasJugadores: .space 12 #Arreglo con las fichas de los jugadores en bytes. J1: 0(FichasJugadores) J2: 16(FichasJugadores) J3: 
#FichasJ2:.space 4
#FichasJ3:.space 4
#FichasJ4:.space 4

#NumFichasTablero: .byte 0,0,0,0,0,0,0 #Arreglo con el numero REDUCIR CON EL ARREGLO PORQUE SON MUCHAS ETIQUETAS
#FichasCero:	.word 7 #Contador del numero de fichas que quedan en manos de los jugadores con el numero 1
#FichasUno:      .word 7	#Sirven para determinar si el juego se tranco, buscando las fichas que estan en los bordes de mesa
#FichasDos:	.word 7 #Y viendo si el numero de estas fichas que quedan en las manos de los jugadores es igual a cero
#FichasTres:	.word 7
#FichasCuatro:	.word 7
#FichasCinco:	.word 7
#FichasSeis:	.word 7

TurnoActual:	.word 0 #Indica quien tiene el turno actual (va del 1 al 4)

PuntajeE1:	.word 0
PuntajeE2:	.word 0


	.text
	jal LimpiarPantalla
	jal Init
	b Ciclo2			#Se podria poner a Init como una etiqueta y no como funcion y se salta a Ciclo2 dentro de ella
						#En este punto $s0 contiene el jugador con la cochina
Ciclo1:
	jal Shuffle
	jal ReiniciarValores
	jal RepartirFichas
	jal SalirPrimero
	
	
	
	
Ciclo2:

	jal MensajesPantalla
	move $a1,$s7
	addi $a1,$a1,-1
	jal ImprimirTablero
	############# Parametros ImprimirFichas
	move $a1,$t4  #$a1 esta parado en la ultima ficha del jugador actual
	addi $a1,$a1,-1
	sll $a1,$a1,3 #$a2 esta parado en la primera ficha
	add $a1,$a1,$t2
	lw $a1,0($a1)
	move $a2,$t4
	addi $a2,$a2,-1
	mul $a2,$a2,14
	add $a2,$a2,$t3
	#############
	jal ImprimirFichas
	jal HacerJugada
	move $a0,$t2
	addi $a3,$a0,32
	addi $s0,$zero,0
	jal VerFinRonda
	b Ciclo2



Init:	#Variables que seran globales durante todo el programa para no accesar tanto a memoria, se pueden quitar y pasar como parametros
	la $t2,FichasJugadores		#Apuntador al arreglo FichasJugadores
	la $t3,Fichas			#Comienzo del arreglo con las Fichas
	addi $t4,$zero,0		#Turno (1,2,3,4)
	addi $t5,$zero,0		#Puntos equipo1
	addi $t6,$zero,0		#Puntos equipo2
	la $t7,Tablero			#Apuntador al tablero que se ira moviendo apuntado a la proxima dir libre
	addi $t8,$zero,0		#Contador de turnos pasados
	la $s6,Tablero			#Direccion de un extremo del tablero 
	addi $s7,$s6,1			#Direccion del otro extremo del tablero 
	la $v1,Tablero			#QUITAR ESTA BASURA
	#Colocar aqui mensajes de bienvenida y eso
	#jal ComienzoPrograma
	sw $ra,0($sp)
	addi $sp,$sp,-4
	jal CargarNombres
	jal CargarArchivo  #Abre el archivo,lee su contenido y lo guarda en Archivo
	la $a0,Archivo
	la $a1,Fichas
	move $a2,$a1			#Carga en a2 el valor de a1 para comparar si ya se cargo el arreglo completo ($a1 = $a2+28)
	addi $a2,$a2,56
	jal CargarFichas   #Separa las fichas de los caracteres como ",()" y los coloca en un arreglo
	

	
	la $a2,Fichas			#$a2 posee la direccion del inicio del arreglo
	add $a3,$zero,27 		#$a3 comienza en el final del arreglo y va recorriendolo del final al inicio hasta que $a3=$a2
	
	la $a0,Fichas
	jal RepartirFichas	#Coloca los apuntadores de cada jugador hacia el inicio y el fin de sus fichas en el arreglo Fichas
			
	la $a0,Fichas
	addi $a1,$a0,56
	jal BuscarDoble6
	
	addi $a0,$zero,13878		#Pasando como parametro a la funcion SalirPrimero la ficha que queremos cambiar
					#BuscarDoble6 retorno en $s0 la posicion del arreglo Fichas donde consiguio el doble 6
					#y cambio el valor de $t4 al del jugador que tiene la cochina (coloco el turno al jugador)
	sw $t0,0($sp)
	addi $sp,$sp,-4
	add $a1,$zero,$s0	#Pasando como parametro a SalirPrimero la direccion del arreglo del jugador que posee la ficha ($s0 lo retorno BuscarDoble6)
	jal SalirPrimero
	addi $sp,$sp,4
	lw $t0,0($sp)
					#que no fue usado antes. Depende de si igual hay que guardar todo aunq no se haya usado antes	
	addi $sp,$sp,4			#Recuperando para salir del jal Init
	lw $ra,0($sp)
	jr $ra
	
#USAR UNA MACRO PARA IMPRIMIR COMENTARIOS?
CargarNombres:
	sw $ra,0($sp)
	addi $sp,$sp,-4
	la $a2,NombreJ1
	jal LeerNombre
	la $a2,NombreJ2
	jal LeerNombre
	la $a2,NombreJ3
	jal LeerNombre
	la $a2,NombreJ4
	jal LeerNombre
	addi $sp,$sp,4
	lw $ra,0($sp)
	jr $ra
	
LeerNombre:
	la $a0,Mensaje1
	li $v0,4
	syscall
	
	move $a0,$a2
	li $a1,20
	li $v0,8
	syscall
	
	la $a0,SaltoLinea
	li $v0,4
	syscall
	
	jr $ra
	

CargarArchivo:

	li $v0,13           #open a file
	li $a1,0            # file flag (read)
	la $a0,Path         # load file name
	add $a2, $zero, $zero    # file mode (unused)
	syscall
	
	move $a3,$v0 #Guarda en $s6 el descriptor (numero que indica si se hizo bien el load (lanza num +)o si no (lanza num neg)
	move $a0,$a3
  	bltz $a3,LoadError
  	
	li $v0,14
	la $a1,Archivo
	li $a2,140
	syscall 
	
	li $v0, 16       # system call for close file
	move $a0, $a3      # file descriptor to close
  	syscall            # close file
	jr $ra
  	  	
LoadError:
	la $a0,MensajeLoadError
	li $v0,4
	syscall
	
	li $v0,10
	syscall
	

CargarFichas:
	
	lb $a3,1($a0)			#Carga en $a3 el primer numero del par (a,b) 
	sb $a3,0($a1)			#Guarda en el arreglo Fichas el primer numero del par
	lb $a3,3($a0)
	sb $a3,1($a1)
	addi $a0,$a0,5
	addi $a1,$a1,2
	bne $a1,$a2,CargarFichas
	jr $ra


Shuffle:			#ESTA INEFICIENTE POR TRANSFORMAR a $a3 y $a0 en direcciones y luego en posiciones del arreglo Fichas
				#colocar todo en funcion de direcciones	
	add $a1,$zero,$a3		
	addi $v0,$zero,42		#Se halla un numero random entre 0 y 28
	addi $a0,$a0,0
	syscall
	sll $a3,$a3,1			#$a3 (recorre el arreglo) esta entre 0 y 26 y debe estar entre 0 y 56 para recorrer 
	sll $a0,$a0,1			#el arreglo por medias palabras (de 2 en 2) al igual que el numero random debe ser par y estar entre 0y el valor de $a3
	add $a3,$a3,$a2			#Se coloca $a3 y $a0 en funcion de la direccion del arreglo Fichas 
	add $a0,$a0,$a2			
	lh $a1,0($a0)
	lh $t0,0($a3)			#PREGUNTAR SI HAY QUE GUARDA $T0 en la pila
	sh $t0,0($a0)
	sh $a1,0($a3)
	sub $a3,$a3,$a2			#Se coloca $a3 y $a0 en funcion de la direccion del arreglo Fichas 
	sub $a0,$a0,$a2		
	srl $a3,$a3,1		
	srl $a0,$a0,1
	addi $a3,$a3,-1			#se va disminuyendo el recorredor hasta que llegue al inicio del arreglo
	bnez $a3,Shuffle		#El shuffle termina cuando se ha terminado de recorrer todo el arreglo
	jr $ra
	
RepartirFichas: #Si se va a usar RepartirFichas en todas las rondas se estaria haciendo de mas el asignar el apuntador al inicio del
# segmento de fichas de cada jugador. Se puede separar esa parte y dejar que esta funcion solo actualice los apuntadores de los topes

	la $a1,FichasJugadores		#Guarda los dos apuntadores de cada jugador en el espacio de memoria reservado para c/u
	sw $a0,4($a1)			#El segundo apuntador siempre estara al comienzo del segmento de fichas que le corresponde
	addi $a0,$a0,14			#al jugador en el arreglo Fichas, el primero estara en el tope de las fichas actuales
	sw $a0,0($a1)			#si se juega una ficha, se intercambia la ficha que esta en el tope-2 con la ficha jugada
	sw $a0,12($a1)			#y se le resta 2 al apuntador del tope
	addi $a0,$a0,14			#la ronda termina cuando el apuntador del comienzo de las fichas de un jugador
	sw $a0,8($a1)			#es igual al apuntador del tope.
	sw $a0,20($a1)			#QUITAR APUNTADOR DEL INICIO DE LAS FICHAS DE CADA JUGADOR Y REDUCIR .WORD DE FichasJugadores??
	addi $a0,$a0,14
	sw $a0,16($a1)
	sw $a0,28($a1)
	addi $a0,$a0,14
	sw $a0,24($a1)
	jr $ra
	
	
BuscarDoble6:				#CICLO
	lh $a2,0($a0)
	li $a3,13878			#Guardando el valor del doble 6 para poder buscarlo
	beq $a2,$a3,Encontrado
	addi $a0,$a0,2
	bne $a0,$a1,BuscarDoble6
	
Encontrado:				#IF
	add $s0,$zero,$a0				#En a1 esta el fin de la lista de fichas, le resta 42 y pregunta si la direccion donde encontro
	addi $a1,$a1,-42		#el doble 6 es menor que la direccion donde terminan las fichas del jugador 1. Si es menor
	blt $a0,$a1,SaleJ1		#entonces retorna 1, indicando que comienza el jugador 1, si no suma 14 y pregunta si 
	addi $a1,$a1,14			#la direccion del doble 6 es menor que la dir donde terminan las fichas de j2, si es menor
	blt $a0,$a1,SaleJ2		#entonces el doble 6 esta entre las fichas que pertenecen a j2
	addi $a1,$a1,14
	blt $a0,$a1,SaleJ3
	addi $a1,$a1,14
	blt $a0,$a1,SaleJ4			
	
SaleJ1:
	addi $t4,$zero,1
	jr $ra
SaleJ2:
	addi $t4,$zero,2
	jr $ra
SaleJ3:
	addi $t4,$zero,3
	jr $ra
SaleJ4:
	addi $t4,$zero,4
	jr $ra
	
	
SalirPrimero: #En $a0 esta la ficha que se desea colocar
	
	#Intercambiando la ficha que esta en el tope del segmento de fichas de J1 con la cochina y bajando el apuntador del tope
	move $a2,$t4		#Colocando el turno (1,2,3,4) en $a2 
	addi $a2,$a2,-1		#Se le resta 1 para que pueda indicar la posicion del arreglo de apuntadores a las fichas de los jugad
	sll $a2,$a2,3		#se multiplica x 8 y da el numero de bytes que hay que desplazarse desde el comienzo del arreglo 
				#FichasJugadores para encontrar el apuntador del tope de la pila de fichas del jugador con el turno
				#si se quitan los apuntadores al inicio de los arreglos de fichas hay que colocar 2 en vez de 3
	add $a2,$a2,$t2	#$t2 es un apuntador al arreglo de apuntadores que indican el inicio y fin de las fichas de cada jugador en FichasJugadores
				#$a2 es un apuntador al tope del arreglo de fichas del jugador que jugo la pieza
	lw $t0,0($a2)
	addi $t0,$t0,-2		#Se baja el apuntador a la ficha anterior para indicar que hay una ficha menos
	lh $a3,0($t0)		#se intercambian las fichas del tope con la ficha que se desea sacar del arreglo
	sh $a0,0($t0)
	sh $a3,0($a1)
	sh $a0,0($t7)		#Se agrega al tablero la primera ficha
	sw $t0,0($a2)		#Actualiza el apuntador hacia el tope de la pila de fichas del jugador actual
	addi $t4,$t4,1		#Cambia el turno
	addi $t7,$t7,12
	
	#sw $ra,0($sp)
	#addi $sp,$sp,-4
	#jal ContarFichas
	#addi $sp,$sp,4
	#lw $ra,0($sp)
	jr $ra
	
#ContarFichas: Si se quiere determinar si el juego se tranca en cada turno hay que hacer una funcion que cuente el numero de fichas 
#que hay en el tablero de cada valor	
	

ImprimirTablero:

	lb $a3,1($a1)		#Carga del tablero la parte izquierda de la ficha
	sll $a3,$a3,8		#Hace un shift para poder hacer la mascara
	ori $a3,$a3,40	#Or con una mascara 0000 0000 0010 1000 = 0 0 2 8 con 28 = "(" y 0 0 para dejar el byte del numero
	sw $a3,ImpresionNumero	#Guarda en memoria lo que se desea imprimir
	la $a0,ImpresionNumero	#lo carga de la memoria en $a0
	addi $v0,$zero,4
	syscall
	lb $a2,0($a1)
	sll $a2,$a2,8
	ori $a2,$a2,44	#or con la mascara 0000 0000 0010 1100  = 0 0 2 C con 2C = ","
	sw $a2,ImpresionNumero
	la $a0,ImpresionNumero
	syscall
	addi $a0,$zero,41
	sw $a0,ImpresionNumero
	la $a0,ImpresionNumero		#No se coloca addi $v0,$zero,4 porque ya lo tiene de arriba
	syscall
	lw $a1,8($a1)		#Salta a la siguiente ficha del tablero
	bnez $a1,ImprimirTablero
	la $a0,SaltoLinea
	syscall
	jr $ra
	
	
MensajesPantalla:

	la $a0,MensajePuntos
	addi $v0,$zero,4
	syscall
	la $a0,MensajeEquipo1
	addi $v0,$zero,4
	syscall
	move $a0,$t5
	addi $v0,$zero,1
	syscall
	la $a0,MensajeEquipo2
	addi $v0,$zero,4
	syscall
	move $a0,$t6
	addi $v0,$zero,1
	syscall
	la $a0,MensajeTurno
	addi $v0,$zero,4
	syscall
	beq $t4,1,ImprimirJ1
	beq $t4,2,ImprimirJ2
	beq $t4,3,ImprimirJ3
	beq $t4,4,ImprimirJ4
	
ImprimirJ1:
	la $a0,NombreJ1
	addi $v0,$zero,4
	syscall
	jr $ra
	
ImprimirJ2:
	la $a0,NombreJ2
	addi $v0,$zero,4
	syscall
	jr $ra
	
ImprimirJ3:
	la $a0,NombreJ3
	addi $v0,$zero,4
	syscall
	jr $ra
	
ImprimirJ4:
	la $a0,NombreJ4
	addi $v0,$zero,4
	syscall
	jr $ra

ImprimirFichas:
	lb $a3,0($a2)
	sll $a3,$a3,8
	addi $a3,$a3,40
	sw $a3,ImpresionNumero
	la $a0,ImpresionNumero
	addi $v0,$zero,4
	syscall
	lb $a3,1($a2)
	sll $a3,$a3,8
	addi $a3,$a3,44
	sw $a3,ImpresionNumero
	la $a0,ImpresionNumero
	syscall
	addi $a0,$zero,41
	sw $a0,ImpresionNumero
	la $a0,ImpresionNumero		#No se coloca addi $v0,$zero,4 porque ya lo tiene de arriba
	syscall
	addi $a2,$a2,2
	bne $a1,$a2,ImprimirFichas
	la $a0,SeleccionFicha
	syscall
	la $a0,SeleccionFicha2
	syscall
	jr $ra
	
LimpiarPantalla:
	la $a0,SaltosLinea
	addi $v0,$zero,4
	syscall
	jr $ra

HacerJugada:
	addi $v0,$zero,5
	syscall
	move $a2,$v0
	beqz $v0,PasarTurno
	addi $a2,$a2,-1
	sll $a2,$a2,1
	move $a3,$t4
	addi $a3,$a3,-1
	mul $a3,$a3,14
	add $a3,$a3,$a2
	add $a3,$a3,$t3
	lb $t0,0($a3)			#
	lb $t1,1($a3)
	lb $a0,0($s6)			#$a0 borde derecho
	lb $a1,0($s7)			#$a1 borde izquierdo
	beq $t0,$a0,AgregarDer1		#Valor derecho de la ficha es igual al borde derecho del tablero
	beq $t0,$a1,AgregarIzq1		#Valor derecho de la ficha es igual al borde izquierdo del tablero
	beq $t1,$a0,AgregarDer2		#Valor izquierdo de la ficha es igual al borde derecho del tablero
	beq $t1,$a1,AgregarIzq2		#Valor izquierdo de la ficha es igual al borde izquierdo del tablero
	la $a0,FichaIncorrecta
	addi $v0,$zero,4
	syscall
	j Ciclo2
	
AgregarDer1:
	sb $t0,1($t7)		#Se inserta la ficha en el tablero ($t7 posee la primera direccion libre luego de la ultima ficha agregada
	sb $t1,0($t7)		#Como $t0 es igual al borde derecho del tablero, el valor de $t0 se coloca a la izquierda y asi queda
	sw $t7,8($s6)		#pegado al borde derecho anterior. Ahora el borde es $t1. Luego se enlazan las fichas
	sw $s6,4($t7)
	move $s6,$t7		#Se coloca como borde a $t1 cambiando el apuntador $s6 (borde derecho) sobre la nueva ficha
	addi $sp,$sp,-20
	sw $a0,0($sp)
	sw $a1,4($sp)
	sw $a2,8($sp)
	sw $t0,12($sp)
	sw $ra,16($sp)
	jal Desempilar
	lw $a0,0($sp)
	lw $a1,4($sp)
	lw $a2,8($sp)
	lw $t0,12($sp)
	lw $ra,16($sp)
	addi $sp,$sp,20
	addi $t7,$t7,12		#Se mueve $t7 a la proxima ficha vacia
	addi $t4,$t4,1		#Se cambia el turno
	jr $ra
	
AgregarDer2:				#FALTAAAAA DESCRIBIR COMO FUNCIONA LA ESTRUCTURA DE LA LISTA ENLAZADA DEL TABLERO
	sb $t1,1($t7)
	sb $t0,0($t7)
	sw $t7,8($s6)			#
	sw $s6,4($t7)
	move $s6,$t7
	addi $sp,$sp,-20
	sw $a0,0($sp)
	sw $a1,4($sp)
	sw $a2,8($sp)
	sw $t0,12($sp)
	sw $ra,16($sp)
	jal Desempilar
	lw $a0,0($sp)
	lw $a1,4($sp)
	lw $a2,8($sp)
	lw $t0,12($sp)
	lw $ra,16($sp)
	addi $sp,$sp,20
	addi $t7,$t7,12
	addi $t4,$t4,1
	jr $ra
	
AgregarIzq1:
	sb $t1,1($t7)
	sb $t0,0($t7)			
	move $s3,$s7
	addi $s3,$s3,-1
	sw $t7,4($s3)			
	sw $s3,8($t7)
	move $s7,$t7	
	addi $sp,$sp,-20
	sw $a0,0($sp)
	sw $a1,4($sp)
	sw $a2,8($sp)
	sw $t0,12($sp)
	sw $ra,16($sp)
	jal Desempilar
	lw $a0,0($sp)
	lw $a1,4($sp)
	lw $a2,8($sp)
	lw $t0,12($sp)
	lw $ra,16($sp)
	addi $sp,$sp,20
	addi $s7,$s7,1			#Le suma uno para que apunte al valor de la ficha que estara en el borde izquierdo
	addi $t7,$t7,12
	addi $t4,$t4,1
	jr $ra
	
AgregarIzq2:
	sb $t0,1($t7)
	sb $t1,0($t7)		
	move $s3,$s7
	addi $s3,$s3,-1
	sw $t7,4($s3)			
	sw $s3,8($t7)
	move $s7,$t7			#Actualizando borde izquierdo
	addi $sp,$sp,-20
	sw $a0,0($sp)
	sw $a1,4($sp)
	sw $a2,8($sp)
	sw $t0,12($sp)
	sw $ra,16($sp)
	jal Desempilar
	lw $a0,0($sp)
	lw $a1,4($sp)
	lw $a2,8($sp)
	lw $t0,12($sp)
	lw $ra,16($sp)
	addi $sp,$sp,20
	addi $s7,$s7,1
	addi $t7,$t7,12
	addi $t4,$t4,1
	jr $ra
	

Desempilar:
		 
	move $a0,$t2
	move $a1,$t4
	addi $a1,$a1,-1
	sll $a1,$a1,3
	add $a0,$a0,$a1
	lw $t0,0($a0)
	addi $t0,$t0,-2
	lh $a1,($a3)
	lh $a2,($t0)
	sh $a2,($a3)
	sh $a1,($t0)
	sw $t0,($a0) 		#Actualiza el apuntador al tope de la pila del jugador actual
	jr $ra
	
	
VerFinRonda:

	lw $a1,0($a0)
	lw $a2,4($a0)
	addi $a0,$a0,8
	beq $t8,4,FinRonda
	beq $a0,$3,FinRonda
	bne $a0,$a3,VerFinRonda
	jr $ra
	
FinRonda:		#REVISAR USO DEL $sp
	sw $ra,0($sp)
	addi $sp,$sp,-4
	jal VerFinJuego
	addi $sp,$sp,4
	lw $ra,0($sp)
	j Ciclo1
	
	
ReiniciarValores:

	la $t2,FichasJugadores		#Apuntador al arreglo FichasJugadores
	la $t3,Fichas			#Comienzo del arreglo con las Fichas
	addi $t4,$zero,0		#Turno (1,2,3,4)
	la $t7,Tablero			#Apuntador al tablero que se ira moviendo apuntado a la proxima dir libre
	addi $t8,$zero,0		#Contador de turnos pasados
	la $s6,Tablero			#Direccion de un extremo del tablero 
	addi $s7,$s6,1			#Direccion del otro extremo del tablero
	jr $ra
	

VerFinJuego:

	bgt $t5,99,FinalizarJuego
	bgt $t6,99,FinalizarJuego
	jr $ra

FinalizarJuego:
	#Mostrar puntajes
	#Pedir que se ingrese 0 para terminar juego,1 para volver a jugar
	#Si $v0 es 0, cerrar programa con syscall
	#Si $v0 es 1,saltar a Init con j
	
PasarTurno:
	addi $t4,$t4,1
	beq $t4,4,FinalizarJuego
	j Ciclo2
