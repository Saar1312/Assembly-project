	.data

arreglo: .word 4,2,3
	
	.text
	la $t0,arreglo
	
	lw $t1,4($t0)

	
