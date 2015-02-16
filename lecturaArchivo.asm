.data

path: .asciiz "PIEDRAS.txt"
.align 1 #Si se quita, el comienzo de los valores del archivo cargado empieza en 1003
textSpace: .space 112 #Si el formato de entrada es todas las fichas en linea: 141201066652... entonces es suficiente con 56
		      #si el formato es un par de numeros por cada linea del archivo (se podria dejar un poco mas por si acaso)
 
.text
main:


	li $v0, 13           #open a file
	li $a1, 0            # file flag (read)
	la $a0, path         # load file name
	add $a2, $zero, $zero    # file mode (unused)
	syscall
	move $s6,$v0
	move $a0,$s6
	li $v0,14
	la $a1,textSpace
	li $a2,112
	syscall
	la $a0,textSpace        # address of string to be printed
	li $v0,4            # print string
	syscall
	
	
  ###############################################################
  # Close the file 
  li   $v0, 16       # system call for close file
  move $a0, $s6      # file descriptor to close
  syscall            # close file
  ###############################################################
