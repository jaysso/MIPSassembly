# Jasmine Sreylack Som
# jsom
.data 
buffer: .space 1 
line: .space 3 # max size is 2 bytes + null
.include "hw4_helpers.asm"
.text

##########################################
#  Part #1 Functions
##########################################
setColor:
	# $a0 = int boardsize (any positive number)
	# $a1 = pos p (board position)
	# $a2 = color curColor (color to set the forground and background)
	li $t9, 0xffff0000 # base address of MMIO
	sra $t0, $a1, 16 # $t0 = row
	andi $t1, $a1, 0xffff # $t1 = column
	
	# sra $t4, $a2, 4 # bg
	# sll $t5, $a2, 28 
	# srl $t5, $t5, 28 # fg
   	
	bltz $a0, colorNotSet
	bge $t0, $a0, colorNotSet
	bge $t1, $a0, colorNotSet
	
	mul $t2, $t0, $a0 # $t2 = row * size of row
	add $t2, $t2, $t1 # row * size of row + column
	sll $t2, $t2, 1 # size of half byte
   	add $t2, $t9, $t2 # $t2 = address of array[row][column]
   	
   	sb $a2, 1($t2) #fg & bg; offset by one byte to get 0x2dfe rather than 0xca2d
   	
	li $v0, 1
	jr $ra
	
	colorNotSet:
		li $v0, -1
		jr $ra
#########################################################################################
initBoard:
	# $a0 = board size
	# $a1 = default color (fg & bg)
	li $t0, 0 # row counter
	li $t9, 0xffff0000
	### Prologue ###
	addi $sp, $sp, -28
	sw $ra, 24($sp)
	sw $a0, 20($sp)
	sw $a1, 16($sp)
	sw $s0, 12($sp)
	sw $s1, 8($sp)
	sw $s2, 4($sp)
	sw $s3, 0($sp)
	################
	move $s0, $a0 # boardsize
	move $s1, $a1 # default color
	li $s2, 0
	
	rloop:
		beq $s0, $s2, endDefault
		li $s3, 0 # column counter
		cloop:
			beq $s0, $s3, endCloop
			sll $t3, $s2, 16 # $t3 -> 0x000R0000
			or $t3, $t3, $s3 # 0x000R0000 or 0x0000000C -> 0x000R000C
			move $a0, $s0
			move $a1, $t3
			move $a2, $s1
			jal setColor
			lw $ra, 24($sp)
			
			li $t4, 'E' # E for empty
			mul $t0, $s0, $s2 # $t0 = row * size of row
			add $t0, $t0, $s3 # row * size of row + column
			sll $t0, $t0, 1 # size of half byte
   			add $t0, $t9, $t0 # $t0 = address of array[row][column]
   			sb $t4, 0($t0)
			addi $s3, $s3, 1
			j cloop
	endCloop:
		addi $s2, $s2, 1
		j rloop
	endDefault:
	### Prologue ###
	lw $ra, 24($sp)
	lw $s0, 12($sp)
	lw $s1, 8($sp)
	lw $s2, 4($sp)
	lw $s3, 0($sp)
	addi $sp, $sp, 28
	################
	jr $ra
########################################################################################
getPiece:
	# $a0 = int board size
	# a1 = pos (r, c)
	
	li $t9, 0xffff0000
	sra $t0, $a1, 16 # $t0 = row
	andi $t1, $a1, 0xffff # $t1 = column
	
	bltz $a0, errorPos
	bge $t0, $a0, errorPos
	bge $t1, $a0, errorPos
	
	mul $t2, $t0, $a0 # $t2 = row * size of row
	add $t2, $t2, $t1 # row * size of row + column
	sll $t2, $t2, 1 # size of half byte
   	add $t2, $t9, $t2 # $t2 = address of array[row][column]
	lb $t5, 0($t2) # player position in address
	
	li $t4, 'E'
	beq $t4, $t5, emptyPos
	li $t4, '0'
	beq $t5, $t4, p0Pos
	li $t4, '1'
	beq $t5, $t4, p1Pos
	errorPos:
		li $v0, -2
		jr $ra
	p0Pos:
		li $v0, 0
		jr $ra
	p1Pos:
		li $v0, 1
		jr $ra
	emptyPos:
		li $v0, -1
		jr $ra
##############################################################################3
placePiece:
	# $a0 = int boardsize
	# $a1 = pos (r, c)
	# $a2 = char player
	# $a3 = halfword CColor
	li $t0, '0'
	li $t1, '1'
	li $t9, 0xffff0000
	sra $t2, $a1, 16 # $t0 = row
	andi $t3, $a1, 0xffff # $t1 = column
	
	bltz $a0, errorRC
	bne $t0, $a2, errorP
	okP:
	bge $t2, $a0, errorRC
	bge $t3, $a0, errorRC
	
	mul $t4, $t2, $a0 # $t2 = row * size of row
	add $t4, $t4, $t3 # row * size of row + column
	sll $t4, $t4, 1 # size of half byte
   	add $t4, $t9, $t4 # $t2 = address of array[row][column]
	lb $t5, 0($t4) # player position
	lb $t6, 1($t4) # color position
	li $t0, 'E'
	bne $t5, $t0, posTaken
	sb $a2, 0($t4)
	srl $t6, $t6, 4 
	sll $t6, $t6, 4  # bg -> 0x000000B0 (from board)
	
	beq $a2, $t1, placeP1
	# cColor = [bg1][fg1][bg0][fg0]
	# $t4 = [[bg][fg] (8 bits)][[player/empty(8 bits)]] == halfword
	# getting color for P0
	sll $t8, $a3, 28
	srl $t8, $t8, 28
	j placedPiece
	
	placeP1:
		# getting color for P1
		sll $t8, $a3, 20
		srl $t8, $t8, 28 # player1 colors
	
	placedPiece:
		sll $t8, $t8, 28 
		srl $t8, $t8, 28 # fg
		or $t6, $t6, $t8
		sb $t6, 1($t4)
		li $v0, 1
		jr $ra
	
	errorP:
		beq $t1, $a2, okP
	errorRC:
		li $v0, -1
		jr $ra
	posTaken:
		li $v0, 0
		jr $ra
###################################################################################
loadGame:
	# $a0 = starting address of filename
	# $a1 = address to store the CColor for each player read from file
	### Prologue ###
	addi $sp, $sp, -64
	# p1 count = 56($sp)
	# p0 count = 52($sp)
	# loaded pos = 48($sp)
	# loaded gameboard = 44($sp)
	# loaded cColor = 40($sp)
	sw $ra, 60($sp)
	sw $a0, 36($sp)
	sw $a1, 32($sp)
	sw $s0, 28($sp)
	sw $s1, 24($sp)
	sw $s2, 20($sp)
	sw $s3, 16($sp)
	sw $s4, 12($sp)
	sw $s5, 8($sp)
	sw $s6, 4($sp)
	sw $s7, 0($sp)
	################
	# zeroing out mem
	sw $0, 56($sp) # p1 count
	sw $0, 52($sp) # p0 count
	
	la $s1, buffer
    	la $s2, line
    	li $s3, 0  # current num/char count
    	li $t1, 0  # loop count
    	li $s6, -1  # line count

    	# open file
    	li $v0, 13     # syscall for open file
    	# $a0 = input file name
    	li $a1, 0      # read flag
    	li $a2, 0      # ignore mode 
    	syscall       # open file 
    	move $s0, $v0  # save the file descriptor 
    	bltz $s0, errorR
    
	readLine_loop:
		# read byte from file
    		li $v0, 14     # syscall for read file
    		move $a0, $s0  # file descriptor 
    		move $a1, $s1  # buffer --> for reading only one byte
    		li $a2, 1      # buffer length
    		syscall       

    		blez $v0, readFile_Done # -1 == error

    		# if current byte is a newline
    		lb $t4, ($s1) # loading character
    		li $t0, 10 # checking for newline (ascii)
    		beq $t4, $t0, readCharNL1

    		# else append byte to line
    		li $t0, 32 # checking if charcter is a space
    		beq $t4, $t0, readChar1 # space == whole character
    		add $t5, $s2, $t1 # line address + byte num
    		sb $t4 ($t5)
    		addi $t1, $t1, 1
    	
    	j readLine_loop

	readMoves:
		# [player] [row][col]
		# adding \n to end of string null terminate line
   		add $t5, $t1, $s2
    		sb $0, ($t5) # $s2 == '[value]\n'
    	
    		move $a0, $s2 # starting address of line
    		li $v0, 84 # atoi
    		syscall
    		move $t9, $v0
    		
    		# increment char count to determine value
		addi $s3, $s3, 1
		
		li $t0, 1
		beq $s3, $t0, playerR
		li $t0, 2
		beq $s3, $t0, rowRead
		li $t0, 3
		beq $s3, $t0, colRead
		j errorR
		
		playerR:
			bnez $t9, checkP1
			li $s4, '0'
			# is player0
			li $t0, 1
			lw $t8, 52($sp)
			add $t8, $t8, $t0
			sw $t8, 52($sp)
			j charHandled2
			checkP1:
				li $t0, 1
				bne $t9, $t0, errorR
				# is player 1
				li $s4, '1'
				lw $t8, 56($sp)
				add $t8, $t8, $t0
				sw $t8, 56($sp)
				j charHandled2
		rowRead:
			lw $t0, 44($sp)
			bge $t9, $t0, errorR
			sll $t9, $t9, 16 # 0x000R0000
			sw $t9, 48($sp)
			j charHandled2
		colRead:
			lw $t0, 44($sp)
			bge $t9, $t0, errorR
			lw $t0, 48($sp)
			or $t9, $t9, $t0
			sw $t9, 48($sp)
			
		charHandled2:
			li $t8, 3
			beq $s3, $t8, placeReadPiece
			li $t1, 0
			j readLine_loop
	placeReadPiece:
		# $a0 = int boardsize == 44($sp)
		# $a1 = pos (r, c) == 48($sp)
		# $a2 = char player == $s4
		# $a3 = halfword CColor
		lw $a0, 44($sp)
		lw $a1, 48($sp)
		move $a2, $s4
		lw $a3, 32($sp) # address of CColor
		lw $a3, ($a3)
		jal placePiece
		blez $v0, errorR
		lw $ra 60($sp)
		li $t1, 0
		# reset counter
		li $s3, 0
		j readLine_loop
    
	readCharNL1:
		bgtz $s6, readMoves
		addi $s6, $s6, 1 # incrementing line
	readChar1:
		bgtz $s6, readMoves
		# adding \n to end of string null terminate line
   		add $t5, $t1, $s2
    		sb $0 ($t5) # $s2 == '[value]\n'
    	
    		move $a0, $s2 # starting address of line
    		li $v0, 84 # atoi
    		syscall
    		move $t9, $v0
    	
    		# increment char count to determine value
		addi $s3, $s3, 1 # $s3 == [board]= 1 [fg0] = 2 [bg0] = 3 [fg1] = 4 [bg1] = 5\n
	
		# determining value
		li $t0, 1
		beq $s3, $t0, boardSize
		li $t0, 2
		beq $s3, $t0, fg0First
		li $t0, 3
		beq $s3, $t0, bg0First
		li $t0, 4
		beq $s3, $t0, fg1First
		li $t0, 5
		beq $s3, $t0, bg1First
		j errorR
		boardSize:
			bltz $t9, errorR
			sw $t9, 44($sp)
			j charHandled1
		# 40($sp) = cColor
		# 44($sp) = boardsize
		# cColor = [bg1][fg1][bg0][fg0]
		fg0First:
			li $t8, 15
			bgt $t9, $t8, errorR
			sw $t9, 40($sp)
			j charHandled1
		bg0First:
			li $t8, 15
			bgt $t9, $t8, errorR
			lw $t4, 40($sp)
			sll $t9, $t9, 4
			or $t9, $t9, $t4
			sw $t9, 40($sp)
			j charHandled1
		fg1First:
			li $t8, 15
			bgt $t9, $t8, errorR
			lw $t4, 40($sp)
			sll $t9, $t9, 8
			or $t9, $t9, $t4
			sw $t9, 40($sp)
			j charHandled1
		bg1First:
			li $t8, 15
			bgt $t9, $t8, errorR
			lw $t4, 40($sp)
			sll $t9, $t9, 12
			or $t9, $t9, $t4
			lw $t8, 32($sp)
			sw $t9,($t8)
	
	charHandled1:
		# reset bytes read
    		li $t1, 0 
    		li $t8, 5
    		beq $s3, $t8, setS30
    		j readLine_loop
	setS30:
		li $s3, 0
		addi $s6, $s6, 1
		j readLine_loop
		
	readFile_Done:
    		# close file
    		li $v0 16     # syscall for close file
    		move $a0 $s0  # file descriptor to close
    		syscall       # close file
		
		lw $v0, 52($sp)
		lw $v1, 56($sp) 
		
	### Epilogue ###
	lw $ra, 60($sp)
	lw $s0, 28($sp)
	lw $s1, 24($sp)
	lw $s2, 20($sp)
	lw $s3, 16($sp)
	lw $s4, 12($sp)
	lw $s5, 8($sp)
	lw $s6, 4($sp)
	lw $s7, 0($sp)
	addi $sp, $sp, 64
	################
    		jr $ra
    
	errorR:
	### Epilogue ###
	lw $ra, 60($sp)
	lw $s0, 28($sp)
	lw $s1, 24($sp)
	lw $s2, 20($sp)
	lw $s3, 16($sp)
	lw $s4, 12($sp)
	lw $s5, 8($sp)
	lw $s6, 4($sp)
	lw $s7, 0($sp)
	addi $sp, $sp, 64
	################
		li $v0, -1
		li $v1, -1
		jr $ra
		
###################################################################################	
saveGame:
	# $a0 = address of filename 
	# $a1 = int board size
	# $a2 = cColor = [bg1][fg1][bg0][fg0]
	### Prologue ###
	addi $sp, $sp, -28
	sw $ra, 24($sp)
	sw $a0, 20($sp)
	sw $a1, 16($sp)
	sw $a2, 12($sp)
	sw $s0, 8($sp)
	sw $s1, 4($sp)
	sw $s2, 0($sp)
	################
	li $s2, 0 # counter
	
	# open file
    	li $v0, 13     # syscall for open file
    	# $a0 = input file name
    	li $a1, 1      # read flag
    	li $a2, 0      # ignore mode 
    	syscall       # open file 
    	move $s0, $v0  # save the file descriptor 
    	bltz $s0, errorS
	
	writeR1: # for writing the first row
	
	li $t9, 0
	beq $s2, $t9, boardS
	li $t9, 1
	beq $s2, $t9, spaceW1
	li $t9, 2
	beq $s2, $t9, fgP0
	li $t9, 3
	beq $s2, $t9, spaceW1
	li $t9, 4
	beq $s2, $t9, bgP0
	li $t9, 5
	beq $s2, $t9, spaceW1
	li $t9, 6
	beq $s2, $t9, fgP1
	li $t9, 7
	beq $s2, $t9, spaceW1
	li $t9, 8
	beq $s2, $t9, bgP1
	li $t9, 9
	beq $s2, $t9, newlineW1
	j writeMove
	
	write_loopR1:
	li   $v0, 15       # system call for write to file
  	move $a0, $s0      # file descriptor 
  	la   $a1, buffer   # address of buffer from which to write
	move $a2, $t0
  	syscall            # write to file
	bltz $v0, errorS
	addi $s2, $s2, 1
	j writeR1
	
	###### branches for first row ######
    	boardS: # writing boardsize:
	lw $a0, 16($sp) # boardsize
	j run_itoaR1

    	# writing cColor:
    	fgP0: lw $a0, 12($sp) # cColor = [bg1][fg1][bg0][fg0]
    	sll $a0, $a0, 28
    	srl $a0, $a0, 28
	j run_itoaR1
	
	bgP0: lw $a0, 12($sp) # cColor = [bg1][fg1][bg0][fg0]
    	sll $a0, $a0, 24
    	srl $a0, $a0, 28
	j run_itoaR1
	
	fgP1: lw $a0, 12($sp) # cColor = [bg1][fg1][bg0][fg0]
    	sll $a0, $a0, 20
    	srl $a0, $a0, 28
    	j run_itoaR1
    	
    	bgP1: lw $a0, 12($sp) # cColor = [bg1][fg1][bg0][fg0]
    	sll $a0, $a0, 16
    	srl $a0, $a0, 28
    	j run_itoaR1
    	
    	spaceW1:
    		li $t9, 32 # ascii space
    		la $t8, buffer
		sb $t9, 0($t8) # saving to buffer
		li $t0, 1 # setting string len
		j write_loopR1
		
    	newlineW1:
    		li $t9, 10 # ascii newline
    		la $t8, buffer
		sb $t9, 0($t8) #saving to buffer
		li $t0, 1 # setting string len
		j write_loopR1
    	
    	run_itoaR1:
	la $a1, buffer # buffer: .space 1
	li $a2, 3 # max charaters including null
	jal itoa
	lw $ra, 24($sp)
	move $t0, $v0 # returns str len
	bltz $t0, errorS
	j write_loopR1
	##############################################
	writeMove:
	li $s2, 0x00000000 # pos
	writeMove_loop:
	li $s1, 0
	lw $a0, 16($sp) # boardsize for getPiece
	## check if last row
	srl $t0, $s2, 16 # 0x0000000R
	beq $t0, $a0, incC
	#################
	run_getPiece:
	move $a1, $s2
	jal getPiece
	lw $ra, 24($sp)
	move $a0, $v0 # int player
	bgez $v0, run_itoaR
	addi $s2, $s2, 0x00010000
	j writeMove_loop

	incC:
	# check if last col --> end save, else increment column and make row 0
	sll $t2, $s2, 16 # 0x000C0000
	srl $t2, $t2, 16 # 0x0000000C
	addi $t1, $a0, -1
	beq $t2, $t1, savedFile_done
	addi $s2, $t2, 1
	j run_getPiece
	
	
	writePos:
	# add space and newline
	li $t0, 1 
	beq $s1, $t0, spaceWM
	li $t0, 2
	beq $s1, $t0, writeR
	li $t0, 3
	beq $s1, $t0, spaceWM
	li $t0, 4
	beq $s1, $t0, writeC
	li $t0, 5
	beq $s1, $t0, newlineWM
	addi $s2, $s2, 0x00010000
	j writeMove_loop
	
	writeR:
		srl $a0, $s2, 16 # 0x0000000R
		j run_itoaR
	writeC:
		sll $a0, $s2, 16 # 0x0000000C
		srl $a0, $a0, 16
		j run_itoaR
	spaceWM:
    		li $t9, 32 # ascii space
    		la $t8, buffer
		sb $t9, 0($t8) # saving to buffer
		li $t0, 1 # setting string len
		j write_loop
		
    	newlineWM:
    		li $t9, 10 # ascii newline
    		la $t8, buffer
		sb $t9, 0($t8) #saving to buffer
		li $t0, 1 # setting string len
		j write_loop
	
	write_loop:
	li   $v0, 15       # system call for write to file
  	move $a0, $s0      # file descriptor 
  	la   $a1, buffer   # address of buffer from which to write
	move $a2, $t0
  	syscall            # write to file
	bltz $v0, errorS
	addi $s1, $s1, 1
	j writePos
	
  	run_itoaR:
	la $a1, buffer # buffer: .space 1
	li $a2, 3 # max charaters including null
	jal itoa
	lw $ra, 24($sp)
	move $t0, $v0 # returns str len
	bltz $t0, errorS
	j write_loop

	savedFile_done:
		# Close the file 
  		li $v0, 16       # system call for close file
  		move $a0, $s0     # file descriptor to close
  		syscall            # close file
  	### Epilogue ###
	lw $ra, 24($sp)
	lw $s0, 8($sp)
	lw $s1, 4($sp)
	lw $s2, 0($sp)
	addi $sp, $sp, 28
	################
		li $v0, 0
		jr $ra
		
	errorS:
		# Close the file 
  		li $v0, 16       # system call for close file
  		move $a0, $s0     # file descriptor to close
  		syscall            # close file
  	### Epilogue ###
	lw $ra, 24($sp)
	lw $s0, 8($sp)
	lw $s1, 4($sp)
	lw $s2, 0($sp)
	addi $sp, $sp, 28
	################
		li $v0, -1
		jr $ra

##########################################
#  Part #2 Functions
##########################################

checkWinR:
	# while True: (check one dir) count += 1 if player == newpos_player else (check other dir)
	# [[bg][fg] (8 bits)][[player/empty(8 bits)]] == halfword, shift 2
	# $a0 = int board size
	# $a1 = pos p
	# $a2 = CColor
	# $a3 = int standard
	### Prologue ###
	addi $sp, $sp, -44
	sw $ra, 40($sp)
	sw $a0, 36($sp)
	sw $a1, 32($sp)
	sw $a2, 28($sp)
	sw $s1, 24($sp) 
	sw $s2, 20($sp) 
	sw $s3, 16($sp)
	sw $s5, 12($sp) 
	sw $s4, 8($sp)
	sw $s0, 4($sp)
	sw $s6, 0($sp)
	################
	li $t9, 0xffff0000
	li $t5, 5
	sra $s4, $a1, 16 # $t0 = row
	andi $s0, $a1, 0xffff # $t1 = column
	mul $s2, $s4, $a0 # $t0 = row * size of row
	add $s2, $s2, $s0 # row * size of row + column
	sll $s2, $s2, 1 # size of half byte
   	add $s2, $t9, $s2 # $s2 = address of array[row][column]
   	lb $s3, 0($s2) # $ s3 = [player turn at pos]
   	lb $t6, 1($s2) # [bg-board][fg-player] 
	li $t7, '0'
	beq $t7, $s3, getBgR0
	# cColor = [bg1][fg1][bg0][fg0]
	
	# p1 colors
		srl $s6, $a2, 8
	j startCheckR

	getBgR0:
		# p0 colors
		sll $s6, $a2, 24
		srl $s6, $s6, 24 # -> 0x000000BF
				
	startCheckR:
		move $t2, $s2 
		li $t7, 1 # piece count
		li $t8, 5
		lw $t6, 36($sp)
		addi $t6, $t6, -1 # max columns
		beq $s0, $t6, othersideR # column in the rightmost
		move $t6, $s0 # column
		lw $t1, 36($sp)
		sll $t0, $t1, 1 # rowlength * 2
		mul $t1, $t1, $t0 # rowlength * 2 * colnum 
		add $t4, $t9 , $t1 # adding a word to address = max address
		standardLoopR:
			beq $t4, $t2, othersideR
			addi $t2, $t2, 2 # adding a halfbyte
			lb $t5, 0($t2) # player position at new pos
			bne $t5, $s3, othersideR
			addi $t7, $t7, 1
			addi $t6, $t6, 1
			lw $t3, 36($sp)
			beq $t6, $t3, othersideR
			j standardLoopR
			othersideR:
				move $t6, $s0 # column
				move $t2, $s2
				beqz $s0, endBoardR # column is the leftmost
				loopotherR:
				beq $t9, $t2, endBoardR
				addi $t2, $t2, -2 # sub a halfbyte
				lb $t5, 0($t2) # player turn at new pos
				bge $t7, $t8, winR # $t7 >= 5
				bne $t5, $s3, noWinR
				addi $t7, $t7, 1
				addi $t6, $t6, -1
				bltz $t6, endBoardR
				j loopotherR
			endBoardR:
				bge $t7, $t8, winR # $t7 >= 5
				j noWinR
			
	winR:
		beqz $a3, startSetR # skip checking value if freestyle
		bne $t7, $t8, noWinR
		startSetR:
		lw $s5, 32($sp) # current pos -> 0x000R000C
		move $s1, $s2
		lw $t6, 36($sp) # boardsize
		addi $t6, $t6, -1 # max columns
		beq $s0, $t6, otherdirR # column in the rightmost
		
		loopsetR: # 5 pieces to win
			sll $t4, $s5, 28 
			srl $t4, $t4, 28
			lw $t3, 36($sp)
			addi $t3, $t3, -1
			bgt $t4, $t3, otherdirR # checking column number; column = boardsize
			lb $t5, 0($s1) # player
			bne $t5, $s3, otherdirR # change direction of color if player not at position
			lw $a0, 36($sp) # $a0 = int boardsize (any positive number)
			
			move $a1, $s5 # $a1 = pos
			move $a2, $s6 # $a2 = color curColor (color to set the forground and background)
			jal setColor
			addi $s5, $s5, 1 # 0x000R000(C+1)
			addi $s1, $s1, 2 # adding a halfword to address
			lw $ra, 40($sp)
			j loopsetR
			otherdirR:
				lw $s5, 32($sp) # back to current pos
				beqz $s0, endR # column is the leftmost
				move $s1, $s2
		
				loopsetOtherR:
					bltz $s5, endR
					lb $t5, 0($s1) # player
					bne $t5, $s3, endR
					lw $a0, 36($sp) # $a0 = int boardsize (any positive number)
					move $a1, $s5
					move $a2, $s6 # $a2 = color curColor (color to set the forground and background)
					jal setColor
					addi $s1, $s1, -2 # sub a halfword
					addi $s5, $s5, -1 # 0x000R000(C-1)
					lw $ra, 40($sp)
					j loopsetOtherR
				
		
	endR:	
	### Epilogue ###
	lw $ra, 40($sp)
	lw $s1, 24($sp) 
	lw $s2, 20($sp) 
	lw $s3, 16($sp)
	lw $s5, 12($sp) 
	lw $s4, 8($sp)
	lw $s0, 4($sp)
	lw $s6, 0($sp)
	addi $sp, $sp, 44
	################
		li $v0, 1
		jr $ra
	
	noWinR:
	### Epilogue ###
	lw $ra, 40($sp)
	lw $s1, 24($sp) 
	lw $s2, 20($sp) 
	lw $s3, 16($sp)
	lw $s5, 12($sp) 
	lw $s4, 8($sp)
	lw $s0, 4($sp)
	lw $s6, 0($sp)
	addi $sp, $sp, 44
	################
		li $v0, 0
		jr $ra

checkWinC:
	# while True: (check one dir) count += 1 if player == newpos_player else (check other dir)
	# [[bg][fg] (8 bits)][[player/empty(8 bits)]] == halfword, shift 2
	# $a0 = int board size
	# $a1 = pos p
	# $a2 = CColor
	# $a3 = int standard
	### Prologue ###
	addi $sp, $sp, -44
	sw $ra, 40($sp)
	sw $a0, 36($sp)
	sw $a1, 32($sp)
	sw $a2, 28($sp)
	sw $s1, 24($sp) 
	sw $s2, 20($sp) 
	sw $s3, 16($sp)
	sw $s5, 12($sp) 
	sw $s4, 8($sp)
	sw $s0, 4($sp)
	sw $s6, 0($sp)
	################
	li $t9, 0xffff0000
	li $t5, 5
	sra $s4, $a1, 16 # $t0 = row
	andi $s0, $a1, 0xffff # $t1 = column
	mul $s2, $s4, $a0 # $t0 = row * size of row
	add $s2, $s2, $s0 # row * size of row + column
	sll $s2, $s2, 1 # size of half byte
   	add $s2, $t9, $s2 # $s2 = address of array[row][column]
   	lb $s3, 0($s2) # $ s3 = [player turn at pos]
   	lb $t6, 1($s2) # [bg-board][fg-player] 
	li $t7, '0'
	beq $t7, $s3, getBgC0
	# cColor = [bg1][fg1][bg0][fg0]
	
	# p1 colors
		srl $s6, $a2, 8
	j startCheckC

	getBgC0:
		# p0 colors
		sll $s6, $a2, 24
		srl $s6, $s6, 24 # -> 0x000000BF
				
	startCheckC:
		move $t2, $s2 
		li $t7, 1 # piece count
		li $t8, 5
		lw $t6, 36($sp)
		addi $t6, $t6, -1 # max rows

		
		lw $t1, 36($sp)
		sll $t4, $t1, 1 # rowlength * 2
		
		
		mul $t1, $t4, $t1 # rowlength * 2 * colnum 
		add $t1, $t9, $t1 # adding a word to address = max address
		beq $s4, $t6, othersideC # row at bottom
		move $t6, $s4 # row
		standardLoopC:
		
			beq $t1, $t2, othersideC
			add $t2, $t2, $t4 # adding a word 
			lb $t5, 0($t2) # player position at new pos
			bne $t5, $s3, othersideC
			addi $t7, $t7, 1
			addi $t6, $t6, 1
			lw $t3, 36($sp)
			beq $t6, $t3, othersideC
			j standardLoopC
			othersideC:
				move $t6, $s4 # row
				move $t2, $s2
				beqz $s4, endBoardC # top row
				loopotherC:
				add $t1, $t9, $t4 # min address to have before reaching last row
				blt $t2, $t1 endBoardC
				sub $t2, $t2, $t4  # sub a word
				lb $t5, 0($t2) # player turn at new pos
				bge $t7, $t8, winC # $t7 >= 5
				bne $t5, $s3, noWinC
				addi $t7, $t7, 1
				addi $t6, $t6, -1
				bltz $t6, endBoardC
				j loopotherC
			endBoardC:
				bge $t7, $t8, winC # $t7 >= 5
				j noWinC
			
	winC:
		beqz $a3, startSetC # skip checking value if freestyle
		bne $t7, $t8, noWinC
		startSetC:
		lw $s5, 32($sp) # current pos -> 0x000R000C
		move $s1, $s2 # duplicate address
		lw $t6, 36($sp) # boardsize
		addi $t6, $t6, -1 # max rows
		beq $s4, $t6, otherdirC # bottom row
		
		loopsetC: # 5 pieces to win
			lw $t1, 36($sp)
			sll $s0, $t1, 1 # rowlength * 2
			mul $t1, $s0, $t1 # rowlength * 2 * colnum 
			add $t1, $t9, $t1 # adding a word to address = max address
			beq $t1, $s1, otherdirC # checking row number; row = boardsize -> bottom row
			lb $t5, 0($s1) # player
			bne $t5, $s3, otherdirC # change direction of color if player not at position
			lw $a0, 36($sp) # $a0 = int boardsize (any positive number)
			move $a1, $s5 # $a1 = pos
			move $a2, $s6 # $a2 = color curColor (color to set the forground and background)
			jal setColor
			# incrementing row
			li $t4, 0x00010000
			add $s5, $s5, $t4
			add $s1, $s1, $s0 # adding a word to address
			lw $ra, 40($sp)
			j loopsetC
			otherdirC:
				lw $s5, 32($sp) 
				beqz $s4, endC # top row
				loopsetOtherC:
					li $t4, 0xffff0000
					blt $s2, $t4, endC
					lb $t5, 0($s2) # player
					bne $t5, $s3, endC
					lw $a0, 36($sp) # $a0 = int boardsize (any positive number)
					move $a1, $s5
					move $a2, $s6 # $a2 = color curColor (color to set the forground and background)
					jal setColor
					# decrementing row
					li $t4, 0x00010000
					sub $s5, $s5, $t4
					# decrementing address
					sub $s2, $s2, $s0 # adding a word to address
					lw $ra, 40($sp)
					j loopsetOtherC
				
		
	endC:	
	### Epilogue ###
	lw $ra, 40($sp)
	lw $s1, 24($sp) 
	lw $s2, 20($sp) 
	lw $s3, 16($sp)
	lw $s5, 12($sp) 
	lw $s4, 8($sp)
	lw $s0, 4($sp)
	lw $s6, 0($sp)
	addi $sp, $sp, 44
	################
		li $v0, 1
		jr $ra
	
	noWinC:
	### Epilogue ###
	lw $ra, 40($sp)
	lw $s1, 24($sp) 
	lw $s2, 20($sp) 
	lw $s3, 16($sp)
	lw $s5, 12($sp) 
	lw $s4, 8($sp)
	lw $s0, 4($sp)
	lw $s6, 0($sp)
	addi $sp, $sp, 44
	################
		li $v0, 0
		jr $ra

checkWinD:
	# while True: (check one dir) count += 1 if player == newpos_player else (check other dir)
	# [[bg][fg] (8 bits)][[player/empty(8 bits)]] == halfword, shift 2
	# $a0 = int board size
	# $a1 = pos p
	# $a2 = CColor
	# $a3 = int standard
	### Prologue ###
	addi $sp, $sp, -48
	sw $ra, 44($sp)
	sw $a0, 40($sp)
	sw $a1, 36($sp)
	sw $a2, 32($sp)
	sw $s1, 28($sp) 
	sw $s2, 24($sp) 
	sw $s3, 20($sp)
	sw $s5, 16($sp) 
	sw $s4, 12($sp)
	sw $s0, 8($sp)
	sw $s6, 4($sp)
	sw $s7, 0($sp)
	################
	li $s7, 0
	li $t9, 0xffff0000
	li $t5, 5
	sra $s4, $a1, 16 # $t0 = row
	andi $s0, $a1, 0xffff # $t1 = column
	mul $s2, $s4, $a0 # $t0 = row * size of row
	add $s2, $s2, $s0 # row * size of row + column
	sll $s2, $s2, 1 # size of half byte
   	add $s2, $t9, $s2 # $s2 = address of array[row][column]
   	lb $s3, 0($s2) # $ s3 = [player turn at pos]
   	lb $t6, 1($s2) # [bg-board][fg-player] 
	li $t7, '0'
	beq $t7, $s3, getBgD0
	# cColor = [bg1][fg1][bg0][fg0]
	
	# p1 colors
		srl $s6, $a2, 8
	j startCheckD

	getBgD0:
		# p0 colors
		sll $s6, $a2, 24
		srl $s6, $s6, 24 # -> 0x000000BF
				
	startCheckD:
		move $t2, $s2 
		li $t7, 1 # piece count
		li $t8, 5
		lw $t1, 40($sp)
		sll $t1, $t1, 1 # rowlength * 2
		mul $t1, $t4, $t1 # rowlength * 2 * colnum 
		add $t1, $t9, $t1 # adding a word to address = max address
		move $t6, $s4 # row
		move $t3, $s0
		lw $t0, 40($sp)
		addi $t0, $t0, -1
		beq $s4, $t0, othersideLD # bottom row
		beq $s0, $t0, othersideLD # rightmost col
		standardLoopLD:
			beq $t1, $t2, othersideLD
			lw $t4, 40($sp)
			sll $t4, $t4, 1
			addi $t4, $t4, 2
			add $t2, $t2, $t4 # adding a word + 2
			lb $t5, 0($t2) # player position at new pos
			bne $t5, $s3, othersideLD
			addi $t7, $t7, 1
			addi $t6, $t6, 1
			addi $t3, $t3, 1
			lw $t0, 40($sp)
			beq $t6, $t0, othersideLD
			beq $t3, $t0, othersideLD
			j standardLoopLD
			othersideLD:
				move $t6, $s4 # row
				move $t3, $s0 # col
				move $t2, $s2
				beqz $s0, endBoardLD # leftmost col
				loopotherLD:
				lw $t1, 40($sp)
				sll $t1, $t1, 1
				add $t1, $t9, $t1 # min address to have before reaching last row
				blt $t2, $t1, endBoardLD
				lw $t4, 40($sp)
				sll $t4, $t4, 1
				addi $t4, $t4, 2
				sub $t2, $t2, $t4  # sub a word + 2
				lb $t5, 0($t2) # player turn at new pos
				bne $t5, $s3, endBoardLD
				addi $t7, $t7, 1
				addi $t3, $t3, -1
				bltz $t3, endBoardLD
				addi $t6, $t6, -1
				bltz $t6, endBoardLD
				j loopotherLD
	standardLoopRD:
		li $t7, 1
		move $t6, $s4
		move $t3, $s0
		move $t2, $s2
		lw $t0, 40($sp)
		addi $t0, $t0, -1
		beq $s4, $t0, othersideRD # bottom row
		beqz $s0, othersideRD # leftmost col
		lw $t1, 40($sp)
		sll $t1, $t1, 1 # rowlength * 2
		mul $t1, $t4, $t1 # rowlength * 2 * colnum 
		add $t1, $t9, $t1 # adding a word to address = max address
		loopRD:
			beq $t1, $t2, othersideRD
			lw $t4, 40($sp)
			sll $t4, $t4, 1
			addi $t4, $t4, -2
			add $t2, $t2, $t4 # adding a word 
			lb $t5, 0($t2) # player position at new pos
			bne $t5, $s3, othersideRD
			addi $t7, $t7, 1
			addi $t6, $t6, 1
			addi $t3, $t3, -1
			lw $t0, 40($sp)
			beqz $t3, othersideRD
			beq $t6, $t0, othersideRD
			j loopRD
			othersideRD:
				move $t6, $s4 # row
				move $t3, $s0 # column
				move $t2, $s2
				beqz $s4, endBoardRD # top row
				loopotherRD:
				add $t1, $t9, $t4 # min address to have before reaching last row
				blt $t2, $t1, endBoardRD
				lw $t4, 40($sp)
				sll $t4, $t4, 1
				addi $t4, $t4, -2
				sub $t2, $t2, $t4  # sub a word -2
				lb $t5, 0($t2) # player turn at new pos
				bne $t5, $s3, endBoardRD
				addi $t7, $t7, 1
				lw $t0, 40($sp)
				addi $t3, $t3, 1
				beq $t3, $t0, endBoardRD
				addi $t6, $t6, -1
				beqz $t6, endBoardRD
				j loopotherRD
			
			endBoardLD:
				bge $t7, $t8, winLD # $t7 >= 5
				j standardLoopRD
			endBoardRD:
				bge $t7, $t8, winRD # $t7 >= 5
				bnez $s7, endD
				j noWinD
			
	winLD:

		beqz $a3, startSetLD # skip checking value if freestyle
		bne $t7, $t8, noWinD
		startSetLD:
		li $s7, 1 # for return value
		lw $s5, 36($sp) # current pos -> 0x000R000C
		move $s1, $s2 # duplicate address
		lw $t0, 40($sp)
		addi $t0, $t0, -1
		beq $s4, $t0, otherdirLD # bottom row
		beq $s0, $t0, otherdirLD # rightmost col
		
		loopsetLD: # 5 pieces to win
			lw $t1, 40($sp)
			sll $t1, $t1, 1 # rowlength * 2
			mul $t1, $t1, $t1 # rowlength * 2 * colnum 
			add $t1, $t9, $t1 # adding a word to address = max address
			beq $t1, $s1, otherdirLD # checking row number; row = boardsize -> bottom row
			lb $t5, 0($s1) # player
			bne $t5, $s3, otherdirLD # change direction of color if player not at position
			lw $a0, 40($sp) # $a0 = int boardsize (any positive number)
			move $a1, $s5 # $a1 = pos
			move $a2, $s6 # $a2 = color curColor (color to set the forground and background)
			jal setColor
			# incrementing row
			li $t4, 0x00010001
			add $s5, $s5, $t4
			# incrementing address
			lw $t4, 40($sp)
			sll $t4, $t4, 1
			addi $t4, $t4, 2
			add $s1, $s1, $t4 # adding a word +2 to address
			lw $ra, 44($sp)
			j loopsetLD
			otherdirLD:
				lw $s5, 36($sp) ##############
				beqz $s4, standardLoopRD # top row
				move $s1, $s2
				loopsetOtherLD:
					li $t4, 0xffff0000
					blt $s1, $t4, standardLoopRD
					lb $t5, 0($s1) # player
					bne $t5, $s3, standardLoopRD
					lw $a0, 40($sp) # $a0 = int boardsize (any positive number)
					move $a1, $s5
					move $a2, $s6 # $a2 = color curColor (color to set the forground and background)
					jal setColor
					# decrementing row
					li $t4, 0x00010001
					sub $s5, $s5, $t4
					# decrementing address
					lw $t4, 40($sp)
					sll $t4, $t4, 1
					addi $t4, $t4, 2
					sub $s1, $s1, $t4 # subbing a word +2 to address
					lw $ra, 44($sp)
					j loopsetOtherLD
	winRD:
		beqz $a3, startSetRD # skip checking value if freestyle
		bne $t7, $t8, noWinD
		startSetRD:
		lw $s5, 36($sp) # current pos -> 0x000R000C
		move $s1, $s2 # duplicate address
		## checks
		lw $t0, 40($sp)
		addi $t0, $t0, -1
		beq $s4, $t0, otherdirRD # bottom row
		beqz $s0, otherdirRD # leftmost col
		
		
		loopsetRD: # 5 pieces to win
			lw $t1, 40($sp)
			sll $s0, $t1, 1 # rowlength * 2
			mul $t1, $s0, $t1 # rowlength * 2 * colnum 
			add $t1, $t9, $t1 # adding a word to address = max address
			bge $s1, $t1, otherdirRD # checking row number; row = boardsize -> bottom row
			lb $t5, 0($s1) # player
			bne $t5, $s3, otherdirRD # change direction of color if player not at position
			lw $a0, 40($sp) # $a0 = int boardsize (any positive number)
			move $a1, $s5 # $a1 = pos
			move $a2, $s6 # $a2 = color curColor (color to set the forground and background)
			jal setColor
			# incrementing row
			li $t4, 0x00010000
			sub $s5, $s5, $t4
			li $t4, 0x00000001
			add $s5, $s5, $t4
			# incrementing address
			lw $t4, 40($sp)
			sll $t4, $t4, 1
			addi $t4, $t4, -2
			add $s1, $s1, $t4 # adding a word -2 to address
			lw $ra, 44($sp)
			j loopsetRD
			otherdirRD:
				lw $s5, 36($sp) ##############
				beqz $s4, endD # top row
				move $s1, $s2
				loopsetOtherRD:
					li $t4, 0xffff0000
					blt $s1, $t4, endD
					lb $t5, 0($s1) # player
					bne $t5, $s3, endD
					lw $a0, 40($sp) # $a0 = int boardsize (any positive number)
					move $a1, $s5
					move $a2, $s6 # $a2 = color curColor (color to set the forground and background)
					jal setColor
					# decrementing row
					li $t4, 0x00010000
					add $s5, $s5, $t4
					li $t4, 0x00000001
					sub $s5, $s5, $t4
					# decrementing address
					lw $t4, 40($sp)
					sll $t4, $t4, 1
					addi $t4, $t4, -2
					sub $s1, $s1, $t4 # subbing a word -2 to address
					lw $ra, 44($sp)
					j loopsetOtherRD
					
		
	endD:	
	### Epilogue ###
	lw $ra, 44($sp)
	lw $s1, 28($sp) 
	lw $s2, 24($sp) 
	lw $s3, 20($sp)
	lw $s5, 16($sp) 
	lw $s4, 12($sp)
	lw $s0, 8($sp)
	lw $s6, 4($sp)
	lw $s7, 0($sp)
	addi $sp, $sp, 48
	################
		li $v0, 1
		jr $ra
	
	noWinD:
	li $t0, 1
	beq $s7, $t1, endD
	### Epilogue ###
	lw $ra, 44($sp)
	lw $s1, 28($sp) 
	lw $s2, 24($sp) 
	lw $s3, 20($sp)
	lw $s5, 16($sp) 
	lw $s4, 12($sp)
	lw $s0, 8($sp)
	lw $s6, 4($sp)
	lw $s7, 0($sp)
	addi $sp, $sp, 48
	################
		li $v0, 0
		jr $ra


checkWin:
	# $a0 = int board size
	# $a1 = pos p
	# $a2 = ccolor
	# $a3 = int standard
	### Prologue ##
	addi $sp, $sp, -28
	sw $ra, 24($sp)
	sw $a0, 20($sp)
	sw $a1, 16($sp)
	sw $a2, 12($sp)
	sw $a3, 8($sp)
	sw $s0, 4($sp)
	sw $s1, 0($sp)
	##############
	lw $a0, 20($sp)
	lw $a1, 16($sp)
	lw $a2, 12($sp)
	lw $a3, 8($sp)
	jal checkWinR
	lw $ra, 24($sp)
	move $s0, $v0
	
	lw $a0, 20($sp)
	lw $a1, 16($sp)
	lw $a2, 12($sp)
	lw $a3, 8($sp)
	jal checkWinC
	lw $ra, 24($sp)
	move $s1, $v0
	
	lw $a0, 20($sp)
	lw $a1, 16($sp)
	lw $a2, 12($sp)
	lw $a3, 8($sp)
	jal checkWinD
	lw $ra, 24($sp)
	bnez $v0, winDone
	bnez $s0, winDone
	bnez $s1, winDone
	
	### Epilogue ##
	lw $ra, 24($sp)
	lw $s0, 4($sp)
	lw $s1, 0($sp)
	addi $sp, $sp, 28
	##############
	li $v0, 0
	jr $ra
	
	winDone:
	### Epilogue ##
	lw $ra, 24($sp)
	lw $s0, 4($sp)
	lw $s1, 0($sp)
	addi $sp, $sp, 28
	##############
	li $v0, 1 
	jr $ra
