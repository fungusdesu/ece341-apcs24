# r2 - temp constants
# r3 - switches states
# r4 - buttons states

# since the output is static per identical button press, no prev states storing is needed

main:
	# load button states
	la $2, 0x80000010
	lw $3, 0($2)
	srl $4, $3, 0xa
	
	# if B0 is enabled
	addiu $2, $0, 0x1
	beq $2, $4, _B0
	
	# if B1 is enabled
	sll $2, $2, 0x1
	beq $2, $4, _B1
	
	# if B2 is enabled
	sll $2, $2, 0x1
	beq $2, $4, _B2
	
	j main
	
_B0:
	# display switches states to LED
	la $2, 0x8000000c
	sh $3, 0($2)
	j main
	
_B1:
	# shifts switches states, then display
	la $2, 0x8000000c
	sll $3, $3, 0x1
	sh $3, 0($2)
	j main

_B2:
	# inverts switches states, then display
	la $2, 0x8000000c
	nor $3, $3, $0
	sh $3, 0($2)
	j main