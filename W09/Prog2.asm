# r2 - temp constants
# r3 - input switches value
# r4 - input buttons value

main:
	addiu $10, $0, 0

_mainLoop:
	la $2, 0x80000010
	lw $3, 0($2)
	srl $3, $3, 0xa
	andi $3, $3, 0x1

	beq $3, $0, main
	
	addiu $2, $0, 0x1
	beq $2, $10, _mainLoop
	beq $2, $3, _B0
	j _mainLoop

_B0:
	la $2, 0x8000000c
	lw $4, 0($2)
	xor $4, $4, 0x1
	sh $4, 0($2)

	addiu $10, $0, 0x1
	j _mainLoop
