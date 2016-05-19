0x0000:
jump error
jump keyboard
jump writechar
jump time

0x0100:
	store ONE 0xFFF2
	load #'A' R0
	push R0
	trap
	pop R0
	load num R0
	load R0 R1
	set TI
        load #0 R6
	move R6 R7
wait:	jumpz R6 wait
	halt

writechar:
	load SP #-1 R0
	store R0 0xFFF0
	reset IM
	return

keyboard:
	store ZERO 0xFFF2
	load #'k' R0
	store R0 0xFFF0
	return

error:
	load #'E' R0
	store R0 0xFFF0
	return

time:   load #'T' R0
	store R0 0xFFF0
        load #1 R6
	reset TI
	return

num:
block #0xFFFFFF
