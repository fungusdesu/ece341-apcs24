.data
	peripheral:	.word 0x80000000
	
	shiftmsg:	.asciiz "Please type a number: "
	msg:		.asciiz "Please type a secret sentence: "
	resultmsg:	.asciiz "Encoded message is: "

.text
main:
	lw $8, peripheral

	la $4, shiftmsg
	jal printString	
	nop
	
	addiu $4, $0, 0x100
	jal readString
	nop
	
	addiu $4, $0, 0x100
	jal atoi
	nop
	
	addiu $26, $2, 0
	la $4, msg
	jal printString
	nop
	
	addiu $4, $0, 0x100
	jal readWithoutEcho
	nop
	
	addiu $4, $0, 0x100
	addiu $5, $26, 0
	jal saladCipher
	nop
	
	la $4, resultmsg
	jal printString
	nop
	
	addiu $4, $0, 0x100
	jal printString
	nop
_mainRequiem:
	j _mainRequiem
	
	

printString:
	# r2 - return value (number of characters written excluding null)
	# r3 - current word
	# r4 - first parameter (address to be read)
	# r5 - current character of word
	# r6 - current byte position
	# r7 - 0x4 (most of the times)
	# r8 - 0x80000000
	addiu $2, $0, 0
	addiu $7, $0, 0x4

	div $4, $7
	mflo $6
	subu $4, $4, $6
	lw $3, 0($4)
	
	addiu $7, $0, 0x8
	mult $7, $6
	mflo $7
	srlv $3, $3, $7
	addiu $7, $0, 0x4
_printStringLoop:
	# print each character in word
	andi $5, $3, 0xff
	beq $5, $0, _printStringStop
	sb $5, 0x8($8)
	addiu $2, $2, 0x1
	addiu $6, $6, 0x1
	
	# if the current word is done, hop to next word
	beq $6, $7, _printStringLoopHop
	
	# otherwise, proceed
	srl $3, $3, 0x8
	j _printStringLoop
	
_printStringLoopHop:
	addiu $4, $4, 0x4
	addiu $6, $0, 0
	
	lw $3, 0($4)
	j _printStringLoop
_printStringStop:
	jr $31
	
	
	
	
readString:
	# r2: return value (number of characters read from buffer)
	# r4: first parameter (address to be read)
	# r5: current byte position
	# r6: temp
	# r8: 0x80000000
	# r9: status or character in buffer
	addiu $2, $0, 0
	addiu $6, $0, 0x4 # how many bytes a word has
	
	div $4, $6
	mflo $5
	subu $4, $4, $5
	addiu $4, $4, 0x3
	
_readStringLoop:
	# keep looping until a character enters the buffer
	lb $9, 0($8)
	beq $0, $9, _readStringLoop

	# if the character is newline, terminate
	lb $9, 0x4($8)
	addiu $6, $0, 0x0a
	beq $9, $6, _readStringStop

	# otherwise store to RAM and modify states
	sb $9, 0($4)
	sb $9, 0x8($8)
	subiu $4, $4, 0x1
	addiu $2, $2, 0x1
	addiu $5, $5, 0x1
	
	# if the current word is done, hop to next word
	addiu $6, $0, 0x4
	beq $5, $6, _readStringLoopHop
	
	# otherwise, jumpwah
	j _readStringLoop
_readStringLoopHop:
	addiu $4, $4, 0x8
	addiu $5, $0, 0
	j _readStringLoop
_readStringStop:
	addiu $6, $0, 0x0a
	sb $6, 0x8($8)
	sb $0, 0($4)
	jr $31
	

readWithoutEcho:
	# r2: return value (number of characters read from buffer)
	# r4: first parameter (address to be read)
	# r5: current byte position
	# r6: temp
	# r8: 0x80000000
	# r9: status or character in buffer
	addiu $2, $0, 0
	addiu $6, $0, 0x4 # how many bytes a word has
	
	div $4, $6
	mflo $5
	subu $4, $4, $5
	addiu $4, $4, 0x3
	
_readWithoutEchoLoop:
	# keep looping until a character enters the buffer
	lb $9, 0($8)
	beq $0, $9, _readWithoutEchoLoop

	# if the character is space or newline, terminate
	lb $9, 0x4($8)
	addiu $6, $0, 0x0a
	beq $9, $6, _readWithoutEchoStop

	# otherwise store to RAM and modify states
	sb $9, 0($4)
	subiu $4, $4, 0x1
	addiu $2, $2, 0x1
	addiu $5, $5, 0x1
	
	# if the current word is done, hop to next word
	addiu $6, $0, 0x4
	beq $5, $6, _readWithoutEchoLoopHop
	
	# otherwise, jumpwah
	j _readWithoutEchoLoop
_readWithoutEchoLoopHop:
	addiu $4, $4, 0x8
	addiu $5, $0, 0
	j _readWithoutEchoLoop
_readWithoutEchoStop:
	addiu $6, $0, 0x0a
	sb $6, 0x8($8)
	sb $0, 0($4)
	jr $31



atoi:
	# r2: return value (parsed integer)
	# r3: sign
	# r4: first parameter (address of string)
	# r5: current character or integer
	# r6: current word
	# r7: temp
	# r8: 0x80000000
	# r10: current byte position
	addiu $2, $0, 0
	addiu $3, $0, 0
	addiu $7, $0, 0x4
	
	div $4, $7
	mflo $10
	subu $4, $4, $10
	lw $6, 0($4)
	
	addiu $7, $0, 0x8
	mult $7, $10
	mflo $7
	srlv $6, $6, $7
	
_atoiPreliminaryLoop:
	# skip whitespace
	andi $5, $6, 0xff
	
	# if the current word is done, hop to next word
	addiu $7, $0, 0x4
	bne $7, $10, _atoiPreliminaryLoopWhitespaceCompare
	addiu $4, $4, 0x4
	addiu $10, $0, 0
	lw $6, 0($4)

_atoiPreliminaryLoopWhitespaceCompare:
	# otherwise, proceed with checking
	addiu $7, $0, 0x20
	beq $5, $7, _atoiPreliminaryLoop
	
	# determine sign
	addiu $7, $0, 0x2d
	beq $5, $7, _atoiAssignNegative
	
_atoiAssignPositive:
	addiu $3, $3, 0x1
	j _atoiCheckDigitLoop
	
_atoiAssignNegative:
	ori $3, $3, 0xffffffff
	addiu $10, $10, 0x1
	srl $6, $6, 0x8
	
	addiu $7, $0, 0x4
	bne $7, $10, _atoiCheckDigitLoop
	addiu $4, $4, 0x4
	addiu $10, $0, 0
	lw $6, 0($4)
	
_atoiCheckDigitLoop:
	# load next or current character depending on sign
	andi $5, $6, 0xff
	addiu $10, $10, 0x1
	srl $6, $6, 0x8
	
	addiu $7, $0, 0x4
	bne $7, $10, _atoiCheckDigitLoopParse
	addiu $4, $4, 0x4
	addiu $10, $0, 0
	lw $6, 0($4)

_atoiCheckDigitLoopParse:	
	# if the character is a valid integer, terminate
	addiu $7, $0, 0x30
	blt $5, $7, _atoiStop
	addiu $7, $0, 0x39
	bgt $5, $7, _atoiStop
	
	# else, parse
	subiu $5, $5, 0x30
	addiu $7, $0, 0xa
	mult $2, $7
	mflo $2
	addu $2, $2, $5
	j _atoiCheckDigitLoop
	
_atoiStop:
	mult $2, $3
	mflo $2
	jr $31
	
	
	
saladCipher:
	# r2 - void return
	# r3 - current word
	# r4 - first parameter (address of string)
	# r5 - second parameter (shift amount)
	# r6 - current character of word
	# r7 - current byte position
	# r9 - temp
	# r10 - temp2
	addiu $2, $0, 0
	addiu $9, $0, 0x4 # how many bytes a word has
	
	div $4, $9
	mflo $7
	subu $4, $4, $7
	lw $3, 0($4)
	
	addiu $9, $0, 0x8
	mult $9, $7
	mflo $9
	srlv $3, $3, $9
	addiu $9, $0, 0x4
_saladCipherLoop:
	# fetch character in word
	andi $6, $3, 0xff
	addiu $7, $7, 0x1
	beq $6, $0, _saladCipherStop

_saladCipherCheckUppercase:
	addiu $9, $0, 0x41
	blt $6, $9, _saladCipherLoopPrepare # no character below 'A' is of interest
	addiu $9, $0, 0x5a
	bgt $6, $9, _saladCipherCheckLowercase # characters above 'Z' are the lowercase
	j _saladCipherEncodeUppercase
	
_saladCipherCheckLowercase:
	addiu $9, $0, 0x61
	blt $6, $9, _saladCipherLoopPrepare # no character between 'Z' and 'a' is of interest
	addiu $9, $0, 0x7a
	bgt $6, $9, _saladCipherLoopPrepare # no character above 'z' is of interest
	j _saladCipherEncodeLowercase

_saladCipherEncodeUppercase:
	addiu $9, $0, 0x41
	j _saladCipherEncode

_saladCipherEncodeLowercase:
	addiu $9, $0, 0x61

_saladCipherEncode:
	# encoded_char = start + ((char - start + shift) % 0x1a)
	# here, start = $9, shift = $5. $6 contains partial results of calculations
	subu $6, $6, $9
	addu $6, $6, $5
	addiu $10, $0, 0x1a
	div $6, $10
	mflo $6
	addu $6, $6, $9
	
	# put back to memory
	addiu $9, $4, 0
	addiu $10, $0, 0x4
	subu $10, $10, $7
	addu $9, $9, $10
	sb $6, 0($9)

_saladCipherLoopPrepare:
	# if the current word is done, hop to next word
	addiu $9, $0, 0x4
	beq $7, $9, _saladCipherLoopHop
	
	# otherwise, proceed
	srl $3, $3, 0x8
	j _saladCipherLoop
	
_saladCipherLoopHop:
	addiu $4, $4, 0x4
	addiu $7, $0, 0
	
	lw $3, 0($4)
	j _saladCipherLoop
_saladCipherStop:
	jr $31
	
	
	
	