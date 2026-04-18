# r2 - temp constants
# r3 - switches states
# r4 - LED value
# r10 - previous button states

main:
	# using a separate register to record previous button states allows edge-triggering
	addiu $10, $0, 0

_mainLoop:
	# fetches current B0 state
	la $2, 0x80000010
	lw $3, 0($2)
	srl $3, $3, 0xa
	andi $3, $3, 0x1

	# if it's disabled, assign previous state as disabled
	beq $3, $0, main
	
	# if the previous state is enabled, do nothing
	bne $10, $0, _mainLoop
	
	# otherwise if the prev state is disabled and curr state is enabled, call toggle
	bne $3, $0, _B0
	
	j _mainLoop

_B0:
	# fetches the LED states, only toggle the last bit, then reassign it
	la $2, 0x8000000c
	lw $4, 0($2)
	xor $4, $4, 0x1
	sh $4, 0($2)

	# toggle prev state
	addiu $10, $0, 0x1
	j _mainLoop