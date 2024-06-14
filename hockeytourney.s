;MADE BY: Jacob Simmons (https://github.com/jacobmsims546)
	AREA RESET, CODE
	THUMB
	ENTRY
Main ;in this branch, the addresses are loaded into r0-r3 and two dummy values are pushed to the bottom of the stack
	ldr r0, =homescores ;r0 = address of homescores
	ldr r1, =awayscores ;r1 = address of awayscores
	ldr r2, =reversedhome ;r2 = address of reversedhome
	ldr r3, =reversedaway ;r3 = address of reversedaway
	mov r4, #0xFF ;move dummy value 0xFF into register 4
	push {r4} ;push dummy value to stack to signal empty stack when it is popped later
	push {r4} ;push another dummy value to stack
PushLoopHome	;in this loop, the individual bytes from homescores are pushed to the stack until the null-terminated word is detected
	ldr r4, [r0] ;r4 = next 4 bytes of homescores
	cmp r4, #0x00000000 ;test to see if these 4 bytes are the null-terminated word 0x00000000
	beq PopLoopHome ;if so, exit loop to PopLoopHome
	ldrb r4, [r0], #1 ;if not, load next byte of homescores into r4 and post-increment 1
	push {r4} ;push the byte to the stack
	add r5, r5, #1 ;post-increment r5 by one, this counter register is used to determine the length of the input, necessary to determine when to end the program later
	b PushLoopHome ;loop back to beginning of this loop
PopLoopHome ;in this loop, the individual bytes from homescores are popped from the stack until the dummy value is detected in order to produce a reversed array named reversedhome
	pop {r4} ;pop top byte pushed onto the stack from homescores into r4
	cmp r4, #0xFF ;test to see if it is one of the dummy values pushed earlier in Main
	beq PushLoopAway ;if so, exit loop to PushLoopAway
	and r6, r4, #0xF0 ;clear the second half of the byte in r4 and store in r6
	lsr r6, #4 ;shift the first half of the byte in r6 to the second half
	strb r6, [r2], #1 ;store this value in reversedhome, post-increment by one
	and r6, r4, #0x0F ;clear the first half of the byte in r4 and store in r6
	strb r6, [r2], #1 ;store this value in reversedhome, post-increment by one
	b PopLoopHome ;loop back to the beginning of this loop
PushLoopAway ;in this loop, the individual bytes from awayscores are pushed to the stack until the null-terminated word is detected
	ldr r4, [r1] ;r4 = next 4 bytes of awayscores
	cmp r4, #0x00000000 ;test to see if these 4 bytes are the null-terminated word 0x00000000
	beq PopLoopAway ;if so, exit loop to PopLoopAway
	ldrb r4, [r1], #1 ;if not, load next byte of awayscores into r4 and post-increment 1
	push {r4} ;push the byte to the stack
	b PushLoopAway ;loop back to the beginning of this loop
PopLoopAway ;in this loop, the individual bytes from awayscores are popped from the stack until the dummy value is detected in order to produce a reversed array named reversedaway
	pop {r4} ;pop top byte pushed onto the stack from awayscores into r4 
	cmp r4, #0xFF ;test to see if it is one of the dummy values pushed earlier in main
	beq SetupforChange ;if so, exit loop to SetupForChange
	and r6, r4, #0xF0 ;clear the second half of the byte in r4 and store in r6
	lsr r6, #4 ;shift the first half of the byte in r6 to the second half
	strb r6, [r3], #1 ;store this value in reversedaway, post-increment by one
	and r6, r4, #0x0F ;clear the first half of the byte in r4 and store in r6
	strb r6, [r3], #1 ;store this value in reversedaway, post-increment by one
	b PopLoopAway ;loop back to the beginning of this loop
SetupforChange ;in this loop, the registers are reassigned to new addresses to save some space, and necessary preparations are made to update scoreboard, winning, and bonus later
	ldr r0, =reversedhome ;r0 = address of reversedhome
	ldr r1, =reversedaway ;r1 = address of reversedaway
	ldr r2, =scoreboard ;r2 = address of scoreboard
	ldr r3, =winning ;r3 = address of winning
	ldr r9, =bonus ;r9 = address of bonus
	mov r4, #0x00 ;clear r4 for use as a game counter
	add r5, r5, r5 ;double the value of r5 and store in r5. the value of r5 is now equal to the amount of bytes in reversed home/away arrays.
ChangeScoreandWinning ;in this loop, the values in scoreboard and winning are updated 
	ldrb r6, [r0] ;the next byte in reversedhome is loaded into r6 
	mov r10, r6 ;this value is copied into r10 for comparision with the value in reversedaway later
	bl Encoder ;break to subroutine Encoder to fill r7 with the seven-segment display code correlating to the number in r6
	strb r7, [r2] ;store the seven-segment display code into scoreboard to display home score
	ldrb r6, [r1] ;the next byte in reversedaway is loaded into r6
	bl Encoder ;break to subroutine Encoder to fill r7 with the seven-segment display code correlating to the number in r6
	strb r7, [r2, #1] ;store the seven-segment display code into scoreboard to display away score
	add r0, r0, #1 ;increment address of reversed home by one to target next value for next loop
	add r1, r1, #1 ;increment address of reversed away by one to target next value for next loop
	add r4, r4, #1 ;increment game counter by one
	cmp r10, r6 ;compare home score to away score
	bgt HomeWins ;if home score > away score, branch to HomeWins
	blt AwayWins ;if away score > home score, branch to AwayWins
	mov r6, #0xFF ;if home score = away score, store 0xFF in r6 
	strb r6, [r3] ;store 0xFF in winning
	b ChangeBonus ;branch to ChangeBonus to update game counter
HomeWins ;in this loop, 0x00 is stored in winning
	mov r6, #0x00 ;store 0x00 in r6
	strb r6, [r3] ;store 0x00 in winning
	b ChangeBonus ;branch to ChangeBonus to update game counter
AwayWins ;in this loop, 0x01 is stored in winning
	mov r6, #0x01 ;store 0x01 in r6
	strb r6, [r3] ;store 0x01 in winning
ChangeBonus ;in this branch, registers r8 and r7 are filled with the correct decimal tens and ones place values corresponding to the game counter r4, which is in hex
	mov r7, #0x00 ;clear register r7
	mov r8, #0x00 ;clear register r8
	and r6, r4, #0x0F ;clear the first half of the counter byte in r4, store in r6
	bl OnesScoreCheck ;break to subroutine OnesScoreCheck to determine the decimal ones and tens equivalent of the hex ones value in r6 and update r7 and r8 accordingly
	and r6, r4, #0xF0 ;clear the second half of the counter byte in r4, store in r6
	asr r6, #4 ;shift the value in r6 right by a half byte
	bl TensScoreCheck ;break to subroutine TensScoreCheck to determine the decimal ones and tens equivalent of the hex tens value in r6 and update r7 and r8 accordingly
	cmp r7, #0x0A ;check to see if the value in r7 is greater than or equal to 10
	bge OnesToTensSplit ;if so, consolidate 10 in r7 into 1 in r8 via OnesToTensSplit
EncodeAndEnd ;in this loop, the values in r7 and r8 are encoded into seven-segment display codes via the encoder subroutine and stored in bonus
	mov r6, r7 ;the value in r7 is copied into r6 for use in the encoder
	bl Encoder ;the encoder is used to determine the seven-segment display code for the game counter's ones place
	strb r7, [r9] ;the game counter's ones place is stored in bonus
	mov r6, r8 ;the value in r8 in copied into r6 for use in the encoder
	bl Encoder ;the encoder is used to determine the seven-segment display code for the game counter's tens place
	strb r7, [r9, #1] ;the game counter's tens place is stored in bonus
	cmp r5, r4 ;check to see if the game counter r4 is equal to the array length r5 
	beq.w Finished ;if so, all games have been displayed, exit program via Finished 
	b ChangeScoreandWinning ;in not, loop back to ChangeScoreandWinning to display more games
OnesScoreCheck ;in this subroutine, the hex ones place value in r6 is tested to be any hex digit and the corresponding decimal equivalent is incremented in r7 and r8
	cmp r6, #0x00 ;test if 0
	beq equaltozero
	cmp r6, #0x01 ;test if 1
	beq equaltoone
	cmp r6, #0x02 ;test if 2
	beq equaltotwo
	cmp r6, #0x03 ;test if 3
	beq equaltothree
	cmp r6, #0x04 ;test if 4
	beq equaltofour
	cmp r6, #0x05 ;test if 5
	beq equaltofive
	cmp r6, #0x06 ;test if 6
	beq equaltosix
	cmp r6, #0x07 ;test if 7
	beq equaltoseven
	cmp r6, #0x08 ;test if 8
	beq equaltoeight
	cmp r6, #0x09 ;test if 9
	beq equaltonine
	cmp r6, #0x0A ;test if 10
	beq equaltoten
	cmp r6, #0x0B ;test if 11
	beq equaltoeleven
	cmp r6, #0x0C ;test if 12
	beq equaltotwelve
	cmp r6, #0x0D ;test if 13
	beq equaltothirteen
	cmp r6, #0x0E ;test if 14
	beq equaltofourteen
	cmp r6, #0x0F ;test if 15
	beq equaltofifteen
	b OnesScoreCheck ;loop if invalid input r6
TensScoreCheck ;in this subroutine, the hex tens place value in r6 is tested to be any hex digit from 0-6 and the corresponding decimal equivalent is incremented in r7 and r8
	cmp r6, #0x00 ;test if 0
	beq equaltozero
	cmp r6, #0x01 ;test if 1
	beq equaltosixteen
	cmp r6, #0x02 ;test if 2
	beq equaltothirtytwo
	cmp r6, #0x03 ;test if 3
	beq equaltofortyeight
	cmp r6, #0x04 ;test if 4
	beq equaltosixtyfour
	cmp r6, #0x05 ;test if 5
	beq equaltoeighty
	cmp r6, #0x06 ;test if 6
	beq equaltoninetysix
	b TensScoreCheck ;loop if invalid input r6
OnesToTensSplit ;in this subroutine, 10 decimal ones are converted into 1 decimal ten
	sub r7, #10 ;r7 = r7 - 10
	add r8, #1 ;r8 = r8 + 1
	b EncodeAndEnd ;break to EncodeAndEnd
equaltozero ;in these branches from the scorecheck subroutines, r7 and r8 are actually updated
	bx lr
equaltoone
	add r7, #0x01 
	bx lr
equaltotwo
	add r7, #0x02
	bx lr
equaltothree
	add r7, #0x03
	bx lr
equaltofour
	add r7, #0x04
	bx lr
equaltofive
	add r7, #0x05
	bx lr
equaltosix
	add r7, #0x06
	bx lr
equaltoseven
	add r7, #0x07
	bx lr
equaltoeight
	add r7, #0x08
	bx lr
equaltonine
	add r7, #0x09
	bx lr
equaltoten
	add r8, #0x01
	bx lr
equaltoeleven
	add r8, #0x01
	add r7, #0x01
	bx lr
equaltotwelve
	add r8, #0x01
	add r7, #0x02
	bx lr
equaltothirteen
	add r8, #0x01
	add r7, #0x03
	bx lr
equaltofourteen
	add r8, #0x01
	add r7, #0x04
	bx lr
equaltofifteen
	add r8, #0x01
	add r7, #0x05
	bx lr
equaltosixteen
	add r8, #0x01
	add r7, #0x06
	bx lr
equaltothirtytwo
	add r8, #0x03
	add r7, #0x02
	bx lr
equaltofortyeight
	add r8, #0x04
	add r7, #0x08
	bx lr
equaltosixtyfour
	add r8, #0x06
	add r7, #0x04
	bx lr
equaltoeighty
	add r8, #0x08
	bx lr
equaltoninetysix
	add r8, #0x09
	add r7, #0x06
	bx lr
Encoder ;in this subroutine, the decimal value in r6 is determined and the corresponding seven-segment display code is stored in r7
	cmp r6, #0x00 ;test if 0
	beq EncodeZero
	cmp r6, #0x01 ;test if 1
	beq EncodeOne
	cmp r6, #0x02 ;test if 2
	beq EncodeTwo
	cmp r6, #0x03 ;test if 3
	beq EncodeThree
	cmp r6, #0x04 ;test if 4, etc...
	beq EncodeFour
	cmp r6, #0x05
	beq EncodeFive
	cmp r6, #0x06
	beq EncodeSix
	cmp r6, #0x07
	beq EncodeSeven
	cmp r6, #0x08
	beq EncodeEight
	cmp r6, #0x09
	beq EncodeNine
	b Encoder ;loop if invalid input r6
EncodeZero ;in these branches from the encoder, r7 is updated to be the correct seven-segment display code for the decimal value in r6
	mov r7, #0x3F
	bx lr
EncodeOne
	mov r7, #0x03
	bx lr
EncodeTwo
	mov r7, #0x5B
	bx lr
EncodeThree
	mov r7, #0x4F
	bx lr
EncodeFour
	mov r7, #0x66
	bx lr
EncodeFive
	mov r7, #0x6D
	bx lr
EncodeSix
	mov r7, #0x7D
	bx lr
EncodeSeven
	mov r7, #0x07
	bx lr
EncodeEight
	mov r7, #0x7F
	bx lr
EncodeNine
	mov r7, #0x77
	bx lr
Finished ;The end of the program is triggered through this branch
	b .
	AREA DATA, DATA
homescores dcd 0x43217408, 0x74929183, 0x61883625, 0 ;packed, null-terminated home score arrays to be unpacked, reversed, and tested against the away score array 
awayscores dcd 0x29281730, 0x11293472, 0x19813471, 0 ;packed, null-terminated away score arrays to be unpacked, reversed, and tested against the home score array
reversedhome space 24 ;reserve space for the reversed arrays, this number must equal the number of games to be played
reversedaway space 24 ;reserve space for the reversed arrays, this number must equal the number of games to be played
scoreboard dcb 0, 0 ;reserve byte space for the scoreboard array
winning dcb 0 ;reserve byte spave for the winning array
bonus dcd 0 ;reserve integer space for the bonus game counter array
	END