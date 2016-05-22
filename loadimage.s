;;;;;; Comp2300 Assignment 2
;; by Andrew Hall (u5825803)

;; This code was completly written by myself, based on my own ideas and research.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;               ######               #####            ##### ;
;              ########              #####            ##### ;
;             ##########             #####            ##### ;
;            #####  #####            #####            ##### ;
;           #####    #####           #####            ##### ;
;          #####      #####          #####            ##### ;
;         #####        #####         #####            ##### ;
;        ####################        ###################### ;
;       ######################       ###################### ;
;      ########################      ###################### ;
;     #####                #####     #####            ##### ;
;    #####                  #####    #####            ##### ;
;   #####                    #####   #####            ##### ;
;  #####                      #####  #####            ##### ;
; #####                        ##### #####            ##### ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Read RPI & ignore
0x100: load 0xFFF0 R0
	jumpz R0 0x100
RL0:   load 0xFFF0 R0
	jumpz R0 RL0
RL1:	load 0xFFF0 R0
	jumpz R0 RL1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Get width

getWidth: load 0xFFF0 R0
	jumpz R0 getWidth
RL2:	load 0xFFF0 R1
	jumpz R1 RL2
RL3:	load 0xFFF0 R2
	jumpz R2 RL3

	mult R0 #100 R0	;R0*100 + R1*10 + R2 - ('0'*100 + '0'*10 + '0')
	mult R1 #10 R1		;this trick replaces 3 subtractions with 1
	add R0 R1 R0
	add R0 R2 R6
	sub R6 #0x14D0 R6	;0x14D0 = '0'*100 + '0'*10 + '0'
	;; store R6 width	;;let R6 == width be used in other parts of the code

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Get height

getHeight: load 0xFFF0 R0
	jumpz R0 getHeight
RL4:	load 0xFFF0 R1
	jumpz R1 RL4
RL5:	load 0xFFF0 R2
	jumpz R2 RL5

	mult R0 #100 R0
	mult R1 #10 R1
	add R0 R1 R0
	add R0 R2 SP			; let SP = height be used elsewhere
	sub SP #0x14D0 SP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Detect which mode to engage, jump to entry point

mode: 	load 0xFFF0 R1
	jumpz R1 mode
	sub R1 #'B' R1
	jumpz R1 binary

	sub R1 #6 R1
	jumpz R1 huffman
	load #0 R1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; hex mode

;    y = 0;
;    int32_t count = 0;
;    int32_t bits;
;    while (y != height){
;        x = 0;
;        int32_t* wordaddr = (output - 1) + 6 * y;
;        int32_t mask = *wordaddr;
;        y++;
;        while (x != width){
;            int32_t bitaddr = x % 32;
;            count = count % 4
;            if (bitaddr == 0){
;                *wordaddr = mask;
;                wordaddr++;
;                mask = 0;
;            }
;            if (count == 0){
;                READCHAR;
;                bits = fromHex(c);
;            }
;            mask |= ((bits >> (3 - count)) & 1) << bitaddr;
;            count++;
;            x++;
;        }
;        *wordaddr = mask;
;    }
;    dump();
;    HALT;
#define X R0
#define Y R1
#define WORDADDR R2
#define MASK R3
#define BITADDR R4
#define C R5
#define WIDTH R6
#define HEIGHT SP
#define COUNT SP

hex: store HEIGHT height
	load #0 COUNT			; count = 0
	jump hexWhileY

hexWhileXCont: store MASK WORDADDR		; *wordaddr = mask
	;; }  placing hexWhileXCont up here removes one jump per row

hexWhileY: load height R7
	sub Y R7 R7		; while (y != height)
	jumpz R7 finish
	load #0 X			; x = 0
	;load #0x7C3F R2		; wordaddr = output - 1
	;mult R1 #6 R7
	;add R2 R7 R2			; wordaddr += 6 * y
	load Y #outSub1Add6y WORDADDR
	load WORDADDR MASK		; mask = *wordaddr
	add Y #1 Y			; y++

hexWhileX: sub X WIDTH R7		; while (x != width){
	jumpz R7 hexWhileXCont
	mod X #32 BITADDR		; bitaddr = x % 32
	mod COUNT #4 COUNT		; count = count % 4

hexIfBitaddr: jumpnz BITADDR hexIfCount	; if (bitaddr == 0){
	;;if body
	store MASK WORDADDR				; *wordaddr = mask
	add WORDADDR #1 WORDADDR			; wordaddr++
	load #0 MASK					; mask = 0
						; }

hexIfCount: jumpnz COUNT hexIfCont		; if (count == 0){
hexRL:	load 0xFFF0 C
	jumpz C hexRL					; c = read character
	load C #fromHex C				; c = fromHex(c)

hexIfCont: sub COUNT #3 R7		; }
	rotate R7 C R7
	and R7 #1 R7
	rotate BITADDR R7 R7
	or MASK R7 MASK 	; mask |= ((bits >> (3 - count)) & 1) << bitaddr;
	add COUNT #1 COUNT			; count++
	add X #1 X				; x++
	jump hexWhileX

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; binary mode

;    y = 0;
;    while (y != height){
;        x = 0;
;        int32_t* wordaddr = (output - 1) + 6 * y;
;        int32_t mask;
;        y++;
;        while (x != width){
;            int32_t bitaddr = x % 32;
;            if (bitaddr == 0){
;                *wordaddr = mask;
;                wordaddr++;
;                mask = 0;
;            }
;            x++;
;
;            READCHAR; //c = read
;            int32_t bit = TOINT(c);
;            mask |= bit << bitaddr;
;        }
;        *wordaddr = mask;
;    }
;    dump();
;    HALT;


binWhileXCont: store MASK WORDADDR		; *wordaddr = mask
	;; }  placing binWhileXCont up here removes one jump per row

binary:
binWhileY: sub Y HEIGHT R7			; while (y != height)
	jumpz R7 finish
	load #0 X 				; x = 0
	load Y #outSub1Add6y WORDADDR
	load WORDADDR MASK			; mask = *wordaddr
	add Y #1 Y				; y++

binWhileX: sub X WIDTH R7			; while (x != width){
	jumpz R7 binWhileXCont
	mod X #32 BITADDR				; bitaddr = x % 32

	jumpnz BITADDR binIfCont			; if (bitaddr == 0) {
	;;if body
	store MASK WORDADDR					; *wordaddr = mask
	add WORDADDR #1 WORDADDR				; wordaddr++
	load #0 MASK						; mask = 0

binIfCont: add X #1 X					; } x++
binRL: load 0xFFF0 C					; c = read char
	jumpz C binRL
	sub C #'0' C					; bit = TOINT(c)

	jumpz C binWhileX	; if bit = 0, there is no need to shift and or

	rotate BITADDR C C				; bit = bit << bitaddr
	or MASK C MASK					; mask = mask | bit
	jump binWhileX				; }


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; huffman mode

; huffman: ;
;    y = 0;
;    x = 0;
;    count = 0;
;    int32_t code = 1;

;cont: ;
;    if (count == 0){
;        READCHAR;
;        c = fromBase64(c);
;        count = 6;
;    }
;    code = code << 1;
;    int32_t tmp = c & 0b100000;
;    tmp = tmp >> 5;
;    code = code | tmp;
;    c = c << 1;
;    count--;
;    switch (code){
;    case 0b100: goto node0;
;    case 0b101: goto node1;
;    case 0b1100: goto node2;
;    case 0b1101: goto node3;
;    case 0b11100: goto node4;
;    case 0b11101: goto node5;
;    case 0b11110: goto node6;
;    case 0b11111: goto node7;
;    default: goto cont;
;   }

#define Count R2
#define Code R3
#define HufC R4

huffman: load #0 X			; x = 0
	load #0 Count			; count = 0
	load #1 Code			; code = 1
	store R6 width
	store SP height

continue: jumpnz Count huffIf1	; if (count == 0){
huffRL:	 load 0xFFF0 HufC				; READCHAR
	jumpz HufC huffRL
	load HufC #fromBase64 HufC			; c = fromBase64(c)
	load #6 Count				;count = 6
					; }
huffIf1: rotate #1 Code Code		; code = code << 1
	and HufC #0x20 R5		; tmp = C & 0b100000
	rotate #-5 R5 R5		; tmp = tmp >> 5
	or Code R5 Code		; code = code | tmp
	rotate #1 HufC HufC		; c = c << 1
	sub Count #1 Count		; count--
	add Code #huffmanDecode PC	; switch(code) -> jump to desired 'node'

finish: halt

huffmanDecode:
jump continue
jump continue
jump continue
jump continue
jump node0
jump node1
jump continue
jump continue
jump continue
jump continue
jump continue
jump continue
jump node2
jump node3
jump continue
jump continue
jump continue
jump continue
jump continue
jump continue
jump continue
jump continue
jump continue
jump continue
jump continue
jump continue
jump continue
jump continue
jump node4
jump node5
jump node6
jump node7

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Node 0

;    x += 8;
;    if (x >= width){
;        y++;
;        x = x % width;
;    }
;    if (y == height){
;        HALT;
;    }
;    code = 1;
;    goto cont;

node0: load #8 R7
set0s:	add X R7 X				; x += cond
	load width R5
	sub X R5 R6				; if (c >= width){
	jumpn R6 nodeIf2
	add Y #1 Y					; y++
	mod X R5 X					; x = x % width
						;}
nodeIf2: load height R5			; if (y == height)
	sub Y R5 R5
	jumpz R5 finish				; HALT

NodeEnd:load #1 Code				; code = 1
	jump continue				; goto cont

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Node 1

;node1: ;
;    temp = 0;
;    while (temp != 8){
;        output[6 * y + x / 32] |= 1 << (x % 32);
;        x++;
;        temp++;
;        if (x == width){
;            x = 0;
;            y++;
;            if (y == height){
;                HALT;
;            }
;        }
;    }
;    code = 1;
;    goto cont;

node1: load #8 R7
	store R7 cond
set1s:	load #0 R5				; temp = 0
node1While: load cond R7
	sub R5 R7 R7			; while (temp != 8){
	jumpz R7 NodeEnd			; code = 1; goto cont
	load Y #outAdd6y R6
	div X #32 R7
	add R7 R6 R6					; R6 = output + 6*y + x / 32
	load R6 R7					; R7 = *R6

	;mod32Shl
	load X #mod32Shl SP				; SP = 1 << (x % 32)

	or R7 SP R7
	store R7 R6					; *R6 = SP | R7
	add X #1 X					; x++
	add R5 #1 R5					; temp ++

	load width R6					; if (x == width){
	sub X R6 R6
	jumpnz R6 node1While
	load #0 X						; x = 0
	add Y #1 Y						; y ++
	load height R6						; if (y == height)
	sub Y R6 R6							; HALT
	jumpz R6 finish
	jump node1While

node2: load #1 R7
	jump set0s
node3:	load #1 R7
	store R7 cond
	jump set1s
node4:	load #2 R7
	jump set0s
node5: load #2 R7
	store R7 cond
	jump set1s
node6: load #4 R7
	jump set0s
node7: load #4 R7
	store R7 cond
	jump set1s

fromHex:
block #0
block #1
block #2
block #3
block #4
block #5
block #6
block #7
block #8
block #9
block #10
block #11
block #12
block #13
block #14
block #15
block #16
block #17
block #18
block #19
block #20
block #21
block #22
block #23
block #24
block #25
block #26
block #27
block #28
block #29
block #30
block #31
block #32
block #33
block #34
block #35
block #36
block #37
block #38
block #39
block #40
block #41
block #42
block #43
block #44
block #45
block #46
block #47
block #0
block #1
block #2
block #3
block #4
block #5
block #6
block #7
block #8
block #9
block #58
block #59
block #60
block #61
block #62
block #63
block #64
block #10
block #11
block #12
block #13
block #14
block #15

fromBase64:
block #0
block #1
block #2
block #3
block #4
block #5
block #6
block #7
block #8
block #9
block #10
block #11
block #12
block #13
block #14
block #15
block #16
block #17
block #18
block #19
block #20
block #21
block #22
block #23
block #24
block #25
block #26
block #27
block #28
block #29
block #30
block #31
block #32
block #33
block #34
block #35
block #36
block #37
block #38
block #39
block #40
block #41
block #42
block #62
block #44
block #45
block #46
block #63
block #52
block #53
block #54
block #55
block #56
block #57
block #58
block #59
block #60
block #61
block #58
block #59
block #60
block #61
block #62
block #63
block #64
block #0
block #1
block #2
block #3
block #4
block #5
block #6
block #7
block #8
block #9
block #10
block #11
block #12
block #13
block #14
block #15
block #16
block #17
block #18
block #19
block #20
block #21
block #22
block #23
block #24
block #25
block #91
block #92
block #93
block #94
block #95
block #96
block #26
block #27
block #28
block #29
block #30
block #31
block #32
block #33
block #34
block #35
block #36
block #37
block #38
block #39
block #40
block #41
block #42
block #43
block #44
block #45
block #46
block #47
block #48
block #49
block #50
block #51

outAdd6y:
block #31808
block #31814
block #31820
block #31826
block #31832
block #31838
block #31844
block #31850
block #31856
block #31862
block #31868
block #31874
block #31880
block #31886
block #31892
block #31898
block #31904
block #31910
block #31916
block #31922
block #31928
block #31934
block #31940
block #31946
block #31952
block #31958
block #31964
block #31970
block #31976
block #31982
block #31988
block #31994
block #32000
block #32006
block #32012
block #32018
block #32024
block #32030
block #32036
block #32042
block #32048
block #32054
block #32060
block #32066
block #32072
block #32078
block #32084
block #32090
block #32096
block #32102
block #32108
block #32114
block #32120
block #32126
block #32132
block #32138
block #32144
block #32150
block #32156
block #32162
block #32168
block #32174
block #32180
block #32186
block #32192
block #32198
block #32204
block #32210
block #32216
block #32222
block #32228
block #32234
block #32240
block #32246
block #32252
block #32258
block #32264
block #32270
block #32276
block #32282
block #32288
block #32294
block #32300
block #32306
block #32312
block #32318
block #32324
block #32330
block #32336
block #32342
block #32348
block #32354
block #32360
block #32366
block #32372
block #32378
block #32384
block #32390
block #32396
block #32402
block #32408
block #32414
block #32420
block #32426
block #32432
block #32438
block #32444
block #32450
block #32456
block #32462
block #32468
block #32474
block #32480
block #32486
block #32492
block #32498
block #32504
block #32510
block #32516
block #32522
block #32528
block #32534
block #32540
block #32546
block #32552
block #32558
block #32564
block #32570
block #32576
block #32582
block #32588
block #32594
block #32600
block #32606
block #32612
block #32618
block #32624
block #32630
block #32636
block #32642
block #32648
block #32654
block #32660
block #32666
block #32672
block #32678
block #32684
block #32690
block #32696
block #32702
block #32708
block #32714
block #32720
block #32726
block #32732
block #32738
block #32744
block #32750
block #32756
block #32762
block #32768

outSub1Add6y:
block #31807
block #31813
block #31819
block #31825
block #31831
block #31837
block #31843
block #31849
block #31855
block #31861
block #31867
block #31873
block #31879
block #31885
block #31891
block #31897
block #31903
block #31909
block #31915
block #31921
block #31927
block #31933
block #31939
block #31945
block #31951
block #31957
block #31963
block #31969
block #31975
block #31981
block #31987
block #31993
block #31999
block #32005
block #32011
block #32017
block #32023
block #32029
block #32035
block #32041
block #32047
block #32053
block #32059
block #32065
block #32071
block #32077
block #32083
block #32089
block #32095
block #32101
block #32107
block #32113
block #32119
block #32125
block #32131
block #32137
block #32143
block #32149
block #32155
block #32161
block #32167
block #32173
block #32179
block #32185
block #32191
block #32197
block #32203
block #32209
block #32215
block #32221
block #32227
block #32233
block #32239
block #32245
block #32251
block #32257
block #32263
block #32269
block #32275
block #32281
block #32287
block #32293
block #32299
block #32305
block #32311
block #32317
block #32323
block #32329
block #32335
block #32341
block #32347
block #32353
block #32359
block #32365
block #32371
block #32377
block #32383
block #32389
block #32395
block #32401
block #32407
block #32413
block #32419
block #32425
block #32431
block #32437
block #32443
block #32449
block #32455
block #32461
block #32467
block #32473
block #32479
block #32485
block #32491
block #32497
block #32503
block #32509
block #32515
block #32521
block #32527
block #32533
block #32539
block #32545
block #32551
block #32557
block #32563
block #32569
block #32575
block #32581
block #32587
block #32593
block #32599
block #32605
block #32611
block #32617
block #32623
block #32629
block #32635
block #32641
block #32647
block #32653
block #32659
block #32665
block #32671
block #32677
block #32683
block #32689
block #32695
block #32701
block #32707
block #32713
block #32719
block #32725
block #32731
block #32737
block #32743
block #32749
block #32755
block #32761
block #32767

mod32Shl:
block #1	;0
block #2	;1
block #4	;2
block #8	;3
block #16	;4
block #32	;5
block #64	;6
block #128	;7
block #256	;8
block #512	;9
block #1024	;10
block #2048	;11
block #4096	;12
block #8192	;13
block #16384	;14
block #32768	;15
block #65536	;16
block #131072	;17
block #262144	;18
block #524288	;19
block #1048576	;20
block #2097152	;21
block #4194304	;22
block #8388608	;23
block #16777216	;24
block #33554432	;25
block #67108864	;26
block #134217728	;27
block #268435456	;28
block #536870912	;29
block #1073741824	;30
block #-2147483648	;31
block #1	;32
block #2	;33
block #4	;34
block #8	;35
block #16	;36
block #32	;37
block #64	;38
block #128	;39
block #256	;40
block #512	;41
block #1024	;42
block #2048	;43
block #4096	;44
block #8192	;45
block #16384	;46
block #32768	;47
block #65536	;48
block #131072	;49
block #262144	;50
block #524288	;51
block #1048576	;52
block #2097152	;53
block #4194304	;54
block #8388608	;55
block #16777216	;56
block #33554432	;57
block #67108864	;58
block #134217728	;59
block #268435456	;60
block #536870912	;61
block #1073741824	;62
block #-2147483648	;63
block #1	;64
block #2	;65
block #4	;66
block #8	;67
block #16	;68
block #32	;69
block #64	;70
block #128	;71
block #256	;72
block #512	;73
block #1024	;74
block #2048	;75
block #4096	;76
block #8192	;77
block #16384	;78
block #32768	;79
block #65536	;80
block #131072	;81
block #262144	;82
block #524288	;83
block #1048576	;84
block #2097152	;85
block #4194304	;86
block #8388608	;87
block #16777216	;88
block #33554432	;89
block #67108864	;90
block #134217728	;91
block #268435456	;92
block #536870912	;93
block #1073741824	;94
block #-2147483648	;95
block #1	;96
block #2	;97
block #4	;98
block #8	;99
block #16	;100
block #32	;101
block #64	;102
block #128	;103
block #256	;104
block #512	;105
block #1024	;106
block #2048	;107
block #4096	;108
block #8192	;109
block #16384	;110
block #32768	;111
block #65536	;112
block #131072	;113
block #262144	;114
block #524288	;115
block #1048576	;116
block #2097152	;117
block #4194304	;118
block #8388608	;119
block #16777216	;120
block #33554432	;121
block #67108864	;122
block #134217728	;123
block #268435456	;124
block #536870912	;125
block #1073741824	;126
block #-2147483648	;127
block #1	;128
block #2	;129
block #4	;130
block #8	;131
block #16	;132
block #32	;133
block #64	;134
block #128	;135
block #256	;136
block #512	;137
block #1024	;138
block #2048	;139
block #4096	;140
block #8192	;141
block #16384	;142
block #32768	;143
block #65536	;144
block #131072	;145
block #262144	;146
block #524288	;147
block #1048576	;148
block #2097152	;149
block #4194304	;150
block #8388608	;151
block #16777216	;152
block #33554432	;153
block #67108864	;154
block #134217728	;155
block #268435456	;156
block #536870912	;157
block #1073741824	;158
block #-2147483648	;159
block #1	;160
block #2	;161
block #4	;162
block #8	;163
block #16	;164
block #32	;165
block #64	;166
block #128	;167
block #256	;168
block #512	;169
block #1024	;170
block #2048	;171
block #4096	;172
block #8192	;173
block #16384	;174
block #32768	;175
block #65536	;176
block #131072	;177
block #262144	;178
block #524288	;179
block #1048576	;180
block #2097152	;181
block #4194304	;182
block #8388608	;183
block #16777216	;184
block #33554432	;185
block #67108864	;186
block #134217728	;187
block #268435456	;188
block #536870912	;189
block #1073741824	;190
block #-2147483648	;191

width : block 1
height : block 1
cond: block 1
