0x100: load 0xFFF0 R0
	jumpz R0 0x100

RL1:	load 0xFFF0 R1
	jumpz R1 RL1

RL2:	load 0xFFF0 R2
	jumpz R2 RL2

RL3:	load 0xFFF0 R3
	jumpz R3 RL3

	store R0 0xFFF0
	store R1 0xFFF0
	store R2 0xFFF0
	store R3 0xFFF0	
