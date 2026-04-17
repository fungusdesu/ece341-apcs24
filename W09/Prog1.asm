main:
la $2, 0x80000010
lw $3, 0($2)

# 0000 0000 0000 0000 0001 1100 0000 0000 (buttons states stored from bit 10 to 12)
la $2, 0x8000000c
sh $3, 0($2)

j main