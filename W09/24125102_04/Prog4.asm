# r2 - temp constants
# r3 - buttons states
# r4 - current counter value
# r10 - previous _B0 states
# r11 - previous _B1 states

main:
	# init - set everything to 0
	sw $0, 0($0)
	la $2, 0x8000000c
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
	
	# if nothing is pressed, update prev state as disabled
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
	# fetches counter value, decrement it, then store it again
	lw $4, 0($0)
	subiu $4, $4, 0x1
	sw $4, 0($0)
	
	# update previous states
	addiu $10, $0, 0x1
	j _output
	
_B1:
	# fetches counter value, increment it, then store it again
	lw $4, 0($0)
	addiu $4, $4, 0x1
	sw $4, 0($0)
	
	# update previous states
	addiu $11, $0, 0x1
	j _output
	
_B2:
	# reset counter value
	addiu $4, $0, 0
	sw $0, 0($0)

_output:
	# display value on LED
	la $2, 0x8000000c
	sw $4, 0($2)
	j _mainLoop
