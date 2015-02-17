	.text

	addi $a1,$zero,28
	addi $v0,$zero,42
	add $a0,$zero,$zero
	syscall
	
	addi $v0,$zero,1
	syscall