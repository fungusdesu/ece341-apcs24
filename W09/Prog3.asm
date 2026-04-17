# r2 - temp constants
# r3 - input switches value
# r4 - input buttons value

main:
la $2, 0x80000010
lw $3, 0($2)

# 0000 0000 0000 0000 0001 1100 0000 0000 (buttons states stored from bit 10 to 12)
srl $3, $3, 0xa
andi $3, $3, 0x1

addiu $2, 0x8000000c
sh $3, 0($2)

j main