.data
	rightArrowTopHalf:	.word 0x7e0c0800
	rightArrowBottomHalf:	.word 0x00080c7e
	downArrowTopHalf:	.word 0x18181800
	downArrowBottomHalf:	.word 0x00183c7e
	leftArrowTopHalf:	.word 0x7e301000
	leftArrowBottomHalf:	.word 0x0010307e
	upArrowTopHalf:		.word 0x7e3c1800
	upArrowBottomHalf:	.word 0x00181818
	
	
	
# r2 - temp constants
# r3 - button states
# r4 - 0x4 or 0x8
# r5 - constant enum indicating the current arrow or memory position of arrow data
#	0 - right arrow
#	1 - down arrow
#	2 - left arrow
#	3 - up arrow
# r6 - arrow data
# r10 - previous B0 state
# r11 - previous B1 state
.text
main:
	# init - set everying to 0
	la $2, 0x80000018
	sw $0, 0($2)
	sw $0, 4($2)
	
	addiu $5, $0, 0
	
_resetPrevState:
	addiu $11, $0, 0

_mainLoop:
	# read button states
	la $2, 0x80000010
	lw $3, 0($2)
	srl $3, $3, 0xb
	andi $3, $3, 0x1
	
	# if nothing is pressed, reset prev states
	beq $3, $0, _resetPrevState
	
	# check buttons conditions
	bne $11, $0, _mainLoop
	bne $3, $0, _B1
	
	j _mainLoop
	
_B1:
	# move to next state
	addiu $5, $5, 0x1
	addiu $4, $0, 0x4
	div $5, $4
	mflo $5
	
	# fetch data to draw
	la $2, 0x80000018
	
	addiu $4, $0, 0x8
	mult $5, $4
	mflo $5
	lw $6, 0($5)
	sw $6, 0($2)
	lw $6, 4($5)
	sw $6, 4($2)
	div $5, $4
	mfhi $5
	
	addiu $11, $0, 0x1
	j _mainLoop
	
