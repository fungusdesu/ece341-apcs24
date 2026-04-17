main:
	addiu $8, $0, 0x80

	sw $0, 0($8)
	la $2, 0x80000014
	sw $0, 0($2)

_resetPrevStates:
	addiu $10, $0, 0
	addiu $11, $0, 0

_mainLoop:
	# read button states
	la $2, 0x80000010
	lw $3, 0($2)
	srl $3, $3, 0xa
	andi $3, $3, 0x7
	
	beq $3, $0, _resetPrevStates

	# check buttons conditions
	addiu $2, $0, 0x1
	beq $2, $10, _mainLoop
	beq $2, $3, _B0
	
	beq $2, $11, _mainLoop
	sll $2, $2, 0x1
	beq $2, $3, _B1
	
	sll $2, $2, 0x1
	beq $2, $3, _B2
	
	j _mainLoop
_B0:
	lb $4, 0($8)
	subiu $4, $4, 0x1
	andi $4, $4, 0xff
	
	addiu $2, $0, 0x9c
	div $4, $2
	mflo $4
	
	sb $4, 0($8)
	
	addiu $10, $0, 0x1
	j _output
	
_B1:
	lb $4, 0($8)
	addiu $4, $4, 0x1
	andi $4, $4, 0xff
	
	addiu $2, $0, 0x64
	div $4, $2
	mflo $4
	
	sb $4, 0($8)
	
	addiu $11, $0, 0x1
	j _output
	
_B2:
	addiu $4, $0, 0
	sw $0, 0($8)

_output:
	la $2, 0x80000014
	sw $4, 0($2)
	j _mainLoop