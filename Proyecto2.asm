	.data 

#HAY ETIQUETAS QUE SE PUEDEN REDUCIR COLOCANDOLAS EN ARREGLOS 


Path:    .asciiz "PIEDRAS.txt"
.align 1 #Si se quita, el comienzo de los valores del archivo cargado empieza en 1003
SaltoLinea: .asciiz "\n"
Mensaje1:.asciiz "Por favor introduzca su nombre (debe tener un maximo de 20 caracteres): "
MensajeLoadError: .asciiz "Error al cargar el archivo. Por favor verifique que el archivo se encuentre en la ruta correcta."

NombreJ1: .space 20
NombreJ2: .space 20
NombreJ3: .space 20
NombreJ4: .space 20

	 .align 1 #Si se quita, el comienzo de los valores del archivo cargado empieza en 1003
Archivo: .space 140	#Se requieren de 5 bytes por ficha para leer las 28 fichas con el formato (1,2)
Fichas:  .space 14      #Para sacar las fichas del formato de entrada (sin "(", ")", ",")
Tablero: .space 84	#Para que cada ficha del tablero tenga una palabra para los dos numeros de la ficha y dos palabras para los
			#apuntadores a la siguiente ficha y a la anterior (esto para poder imprimir el tablero mas facil)
FichasJ1:.space 4	#Para tener las fichas de cada jugador en un arreglo (cada ficha ocupa un byte). Cuando un jugador
			#juegue alguna ficha, esta se quita del arreglo colocando 7 o -1 en lugar del valor que estaba

#FichasJugadores: .space 12 #Arreglo con las fichas de los jugadores en bytes. J1: 0(FichasJugadores) J2: 16(FichasJugadores) J3: 
FichasJ2:.space 4
FichasJ3:.space 4
FichasJ4:.space 4

#NumFichasTablero: .byte 0,0,0,0,0,0,0 #Arreglo con el numero REDUCIR CON EL ARREGLO PORQUE SON MUCHAS ETIQUETAS
FichasCero:	.word 7 #Contador del numero de fichas que quedan en manos de los jugadores con el numero 1
FichasUno:      .word 7	#Sirven para determinar si el juego se tranco, buscando las fichas que estan en los bordes de mesa
FichasDos:	.word 7 #Y viendo si el numero de estas fichas que quedan en las manos de los jugadores es igual a cero
FichasTres:	.word 7
FichasCuatro:	.word 7
FichasCinco:	.word 7
FichasSeis:	.word 7

TurnoActual:	.word 0 #Indica quien tiene el turno actual (va del 1 al 4)

PuntajeE1:	.word 0
PuntajeE2:	.word 0


	.text
	
	jal Init

Init:
	sw $ra,0($sp)
	addi $sp,$sp,-4
	#jal CargarNombres
	jal CargarArchivo  #Abre el archivo,lee su contenido y lo guarda en Archivo
	la $a0,Archivo
	la $a1,Fichas
	move $a2,$a1			#Carga en a2 el valor de a1 para comparar si ya se cargo el arreglo completo ($a1 = $a2+28)
	addi $a2,$a2,56
	jal CargarFichas   #Separa las fichas de los caracteres como ",()" y los coloca en un arreglo
	addi $sp,$sp,4
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
	
	move $s6,$v0 #Guarda en $s6 el descriptor (numero que indica si se hizo bien el load (lanza num +)o si no (lanza num neg)
	move $a0,$s6
  	bltz $s6,LoadError
  	
	li $v0,14
	la $a1,Archivo
	li $a2,140
	syscall 
	
	li $v0, 16       # system call for close file
	move $a0, $s6      # file descriptor to close
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