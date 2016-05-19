0x1: jump writechar

0x100:
	store ONE 0xFFF2
	load #'*' R1
idle:	store R1 0xFFF0
	jump idle

writechar:
	load 0xFFF0 R0
	store R0 0xFFF0
	reset IM
	return

