# r2 - temp constants
# r3 - switches states

main:
la $2, 0x80000010
lw $3, 0($2)

la $2, 0x8000000c
sh $3, 0($2)

j main