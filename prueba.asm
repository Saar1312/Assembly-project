	.data

arreglo: .word 4,2,3
mensaje: .asciiz "Hola wn "
saltos: .asciiz "\n"
mensaje2: .asciiz "Como estas"

limpiaPantalla: "
	.text
	la $a0,mensaje
	li $v0,4
	syscall
	
	la $a0,saltos
	li $v0,4
	syscall

	la $a0,mensaje
	li $v0,4
	syscall
	la $a0,saltos
	li $v0,4
	syscall
	
	la $a0,mensaje
	li $v0,4
	syscall
	la $a0,saltos
	li $v0,4
	syscall
	
