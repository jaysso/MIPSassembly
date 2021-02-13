# Jasmine Sreylack Som
# jsom

.include "hw3_helpers.asm"

.data
str_tb1: .asciiz "tbears( "
str_cntstr: .asciiz "countSubstrs("
str_1: .asciiz "str"
str_comma: .asciiz ", "
str_closepara1: .asciiz ")"
str_closepara: .asciiz " )"
newline: .asciiz "\n"
return_str: .asciiz "return: "
morsecodetxt: .space 500
secretkeytxt: .space 26
size: .word 500

.text

##############################
# PART 1 FUNCTIONS
##############################

tbears:
	# $a0 = intital num of bears (int)
	# $a1 = desired num of bears (int)
	# $a2 = num of bears to ask for (int)
	# $a3 = max num of turn/step to win
	
    ## PROLOGUE ##
    	addi $sp, $sp, -52
	sw $ra, 48($sp)
	sw $a0, 44($sp)
	sw $a1, 40($sp)
	sw $a2, 36($sp)
	sw $a3, 32($sp)
	
	sw $s0, 28($sp)
	sw $s1, 24($sp)
	sw $s2, 20($sp)
	sw $s3, 16($sp)
	sw $s4, 12($sp)
	sw $s5, 8($sp)
	sw $s6, 4($sp)
	sw $s7, 0($sp)
	######
	
	move $s0, $a0
	move $s1, $a1
	move $s2, $a2
	move $s3, $a3
	li $s5, 1
	
		# Printing "tbear( "
		li $v0, 4
		la $a0, str_tb1
		syscall
	
		# Printing intital num
		li $v0, 1
		move $a0, $s0
		syscall
	
		# Printing comma
		li $v0, 4
		la $a0, str_comma
		syscall
	
		# Printing goal
		li $v0, 1
		move $a0, $s1
		syscall
	
		# Printing comma
		li $v0, 4
		la $a0, str_comma
		syscall
		
		# Printing increment
		li $v0, 1
		move $a0, $s2
		syscall
	
		# Printing comma
		li $v0, 4
		la $a0, str_comma
		syscall
	
		# Printing turn
		li $v0, 1
		move $a0, $s3
		syscall

		# Printing " )"
		li $v0, 4
		la $a0, str_closepara
		syscall
		
		# Print newline
		li $v0, 4
		la $a0, newline
		syscall
		
		# IF/ELSE CASES
		beq $s0, $s1, donewin
		beqz $s3, donelose
		
		# RECURSION 1
		add $s4, $s0, $s2 # initial + increment
		addi $s6, $s3, -1 # n - 1
		# setting arguments for recursion
		move $a0, $s4
		move $a1, $s1
		move $a2, $s2
		move $a3, $s6
		jal tbears
		lw $ra, 48($sp)
		move $s7, $v0
		beq $s7, $s5, donewin
		
		andi $s4, $s0, 1
		beqz $s4, even
	donelose:
		li $t0, 0
		j epi
		
	epi:
		# Print return
		li $v0, 4
		la $a0, return_str
		syscall
		
		# Print result
		li $v0, 1
		move $a0, $t0
		syscall
		
		# Print newline
		li $v0, 4
		la $a0, newline
		syscall
		
		## EPILOGUE ##
		lw $ra, 48($sp)
		lw $s0, 28($sp)
		lw $s1, 24($sp)
		lw $s2, 20($sp)
		lw $s3, 16($sp)
		lw $s4, 12($sp)
		lw $s5, 8($sp)
		lw $s6, 4($sp)
		lw $s7, 0($sp)
		addi $sp, $sp, 52
		move $v0, $t0
		jr $ra
	
	donewin:
		li $t0, 1
		j epi
		
		
	
	even:
		li $t0, 2
		# RECURSION 2
		div $s0, $t0
		addi $s6, $s3, -1
		mflo $a0
		move $a1, $s1
		move $a2, $s2
		move $a3, $s6
		jal tbears
		lw $ra, 48($sp)
		move $s7, $v0
		beq $s5, $s7, donewin
		j donelose
		

##################################################################
countSubstrs:
	# $a0 = string
	# $a1 = starting index
	# $a2 = ending index
	# $a3 = len of current substring
	
     ## PROLOGUE ##
    	addi $sp, $sp, -52
	sw $ra, 48($sp)
	sw $a0, 44($sp)
	sw $a1, 40($sp)
	sw $a2, 36($sp)
	sw $a3, 32($sp)
	
	sw $s0, 28($sp)
	sw $s1, 24($sp)
	sw $s2, 20($sp)
	sw $s3, 16($sp)
	sw $s4, 12($sp)
	sw $s5, 8($sp)
	sw $s6, 4($sp)
	sw $s7, 0($sp)
	######
	move $s0, $a0
	move $s1, $a1
	move $s2, $a2
	move $s3, $a3
	li $s5, 1
	li $s4, 0 # res
	
	# PRINTING FUNCTION
		# Printing "countSubstrs( "
		li $v0, 4
		la $a0, str_cntstr
		syscall
	
		# Printing str
		la $a0, str_1
		li $v0, 4
		syscall
	
		# Printing comma
		li $v0, 4
		la $a0, str_comma
		syscall
	
		# Printing i
		li $v0, 1
		move $a0, $s1
		syscall
	
		# Printing comma
		li $v0, 4
		la $a0, str_comma
		syscall
		
		# Printing j
		li $v0, 1
		move $a0, $s2
		syscall
	
		# Printing comma
		li $v0, 4
		la $a0, str_comma
		syscall
	
		# Printing n
		li $v0, 1
		move $a0, $s3
		syscall

		# Printing " )"
		li $v0, 4
		la $a0, str_closepara1
		syscall
		
		# Print newline
		li $v0, 4
		la $a0, newline
		syscall
		
	beq $s3, $s5, done1
	blez $s3, done0
	
	
	#countSubstrs(str, i+1, j, n-1)
	move $a0, $s0 #str
	addi $a1, $s1, 1 # i+1
	move $a2, $s2 # j
	addi $a3, $s3, -1 # n-1
	jal countSubstrs
	lw $ra, 48($sp)
	add $s4, $s4, $v0 
	
	#countSubstrs(str, i, j-1, n-1)
	move $a0, $s0
	move $a1, $s1
	addi $a2, $s2, -1
	addi $a3, $s3, -1
	jal countSubstrs
	lw $ra, 48($sp)
	add $s4, $s4, $v0
	
	#countSubstrs(str, i+1, j-1, n-2)
	move $a0, $s0
	addi $a1, $s1, 1
	addi $a2, $s2, -1
	addi $a3, $s3, -2
	jal countSubstrs
	lw $ra, 48($sp)
	sub $s4, $s4, $v0
	
	add $t1, $s0, $s1
	add $t2, $s0, $s2 
	lb $t3, ($t1)
	lb $t4, ($t2)
	beq $t3, $t4, add1
	
	move $t0, $s4
	j epil
	
	add1:
		addi $s4, $s4, 1
		move $t0, $s4
		j epil
	done1:
    		li $t0, 1
    		j epil
    	done0:
    		li $t0, 0
    		
    	epil:
    		# Print return
		li $v0, 4
		la $a0, return_str
		syscall
		
		# Print result
		li $v0, 1
		move $a0, $t0
		syscall
		
		# Print newline
		li $v0, 4
		la $a0, newline
		syscall
		
		## EPILOGUE ##
		lw $ra, 48($sp)
		lw $s0, 28($sp)
		lw $s1, 24($sp)
		lw $s2, 20($sp)
		lw $s3, 16($sp)
		lw $s4, 12($sp)
		lw $s5, 8($sp)
		lw $s6, 4($sp)
		lw $s7, 0($sp)
		addi $sp, $sp, 52
		move $v0, $t0
		jr $ra


##############################
# PART 2 FUNCTIONS
##############################

toMorse:
	# $a0 = plaintext str address to be converted
	# $a1 = morsecodetext address to store
	# $a2 = size of morsecodetxt
	# $a3 = morsecode array of morse code addresses
	## PROLOGUE ##
    	addi $sp, $sp, -52
	sw $ra, 48($sp)
	sw $a0, 44($sp)
	sw $a1, 40($sp)
	sw $a2, 36($sp)
	sw $a3, 32($sp)
	
	sw $s0, 28($sp)
	sw $s1, 24($sp)
	sw $s2, 20($sp)
	sw $s3, 16($sp)
	sw $s4, 12($sp)
	sw $s5, 8($sp)
	sw $s6, 4($sp)
	sw $s7, 0($sp)
	######
	move $s1, $a1
	move $s2, $a2
	move $s3, $a3
	li $s7, 1 # morsechar counter, null included
	# Changing string to all Uppercase
	jal toUpper
	lw $ra, 48($sp)
	move $s0, $v0
	# char index for array = ascii char - 33
	li $t6, 57
	loop:
		lb $s5, ($s0) # char of plaintext
		addi $s0, $s0, 1 # next byte of plaintext
		#move $a0, $s5
		#li $v0, 11
		#syscall
		
		li $t5, 32
		beq $t5, $s5, endword
		move $s6, $s5
		beq $s2, $s7, fail
		beqz $s5, success
		
		addi $t9, $s5, -33 # getting index of array
		bltz $t9, skip
		bgt $t9, $t6, skip
		sll $t9, $t9, 2 # index * 4
		add $s4, $s3, $t9 # $s4 contains address of char in plaintext for array
		lw $t4, 0($s4)
		move $t7, $t4
		store_byte:
			beq $s2, $s7, fail
			lb $t3, 0($t4)
			sb $t3, ($s1)
			beqz $t3, endchar
			addi $t4, $t4, 1
			addi $s7, $s7, 1
			addi $s1, $s1, 1
			j store_byte
		endword: 
			beq $s6, $s5, skip
			move $s6, $s5
			beq $s2, $s7, fail
			li $t4, 120
			sb $t4, 0($s1)
			addi $s1, $s1, 1
			addi $s7, $s7, 1
			j loop
		endchar:
			beq $t7, $t4, skip
			beq $s2, $s7, fail
			li $t4, 120 # "x"
			sb $t4, ($s1)
			addi $s1, $s1, 1
			addi $s7, $s7, 1
			j loop

	skip:
		j loop
	success:
		li $t4, 120 # "x"
		sb $t4, ($s1)
		addi $s1, $s1, 1
		addi $s7, $s7, 1
		li $t8, 1
		j donemorse
	fail:	li $t8, 0
		
	donemorse:
		# add '\0' to end of morse
		sb, $0 ($s1) # storing null
		move $v0, $s7
		move $v1, $t8
		## EPILOGUE ##
		lw $ra, 48($sp)
		lw $s0, 28($sp)
		lw $s1, 24($sp)
		lw $s2, 20($sp)
		lw $s3, 16($sp)
		lw $s4, 12($sp)
		lw $s5, 8($sp)
		lw $s6, 4($sp)
		lw $s7, 0($sp)
		addi $sp, $sp, 52
		jr $ra
	
	# $v0 = length of morsecode (including '\0')
	# $v1 = 1 if morse code is stored, 0 otherwise


createKey:
    # $a0 = address of message str
    # $a1 = address to store secret key
    ## PROLOGUE ##
    	addi $sp, $sp, -44
	sw $ra, 40($sp)
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
	######
	move $s1, $a1
	jal toUpper
	lw $ra, 40($sp)
	move $s0, $v0
	li $t0, 0 # counter
	li $t1, 0 # counter for loopchk
	lw $s2, 32($sp)
	li $t8, 26
	li $t4, 65
	li $t6, 65
	li $t7, 90
	
	mainloop:
		lb $t3, ($s0)
		addi $s0, $s0, 1
		move $t5, $t3
		beq $t0, $t8, donekey
		beqz $t3, unused
		
	loopchk:
		beq $t1, $t0, loopstore
		lb $t2, 0($s2)
		addi $s2, $s2, 1
		beq $t2, $t3, skip1
		addi $t1, $t1, 1
		j loopchk
		
	loopstore:
		bgt $t3, $t7, skip1
		blt $t3, $t6, skip1
		addi $t0, $t0, 1 
		sb $t3, ($s1)
		addi $s1, $s1, 1
		beqz $t5, unused
	skip1:
		beqz $t5, unused
		li $t1, 0 # reset loopchk
		lw $s2, 32($sp)
		j mainloop
	
	unused:
		li $t1, 0 # reset loopchk
		lw $s2, 32($sp)
		move $t3, $t4
		addi $t4, $t4, 1
		beq $t0, $t8, donekey
		j loopchk
	
	donekey:
		## EPILOGUE ##
		lw $ra, 40($sp)
		lw $s0, 28($sp)
		lw $s1, 24($sp)
		lw $s2, 20($sp)
		lw $s3, 16($sp)
		lw $s4, 12($sp)
		lw $s5, 8($sp)
		lw $s6, 4($sp)
		lw $s7, 0($sp)
		addi $sp, $sp, 44
    		jr $ra

strNcmp:
	# $a0 = str1
	# $a1 = str2
	# $a2 = int n for num of char matches
	## PROLOGUE ##
    	addi $sp, $sp, -48
	sw $ra, 44($sp)
	sw $a0, 40($sp)
	sw $a1, 36($sp)
	sw $a2, 32($sp)
	
	sw $s0, 28($sp)
	sw $s1, 24($sp)
	sw $s2, 20($sp)
	sw $s3, 16($sp)
	sw $s4, 12($sp)
	sw $s5, 8($sp)
	sw $s6, 4($sp)
	sw $s7, 0($sp)
	##
	li $s7, 0 # match counter
	move $s0, $a0
	move $s1, $a1
	move $s2, $a2 # N
	li $t4, 0
	li $t5, 0
	bltz $s2, none # N < 0
	countstr1:
		lb $t0, ($s0)
		addi $s0, $s0, 1
		beqz $t0, countstr2
		addi $t4, $t4, 1
		j countstr1
		
	countstr2:
		lb $t1, ($s1)
		addi $s1, $s1, 1
		beqz $t1, max
		addi $t5, $t5, 1
		j countstr2
	max:
		bgt $s2, $t5, none
		bgt $s2, $t4, none
		lw $s0, 40($sp)
		lw $s1, 36($sp)
		
	bnez $s2, matchnot0 # N != 0
	# if N == 0, must match entirely:
	loop0:
		lb $t0, ($s0)
		lb $t1, ($s1)
		addi $s0, $s0, 1
		addi $s1, $s1, 1
		bne $t0, $t1, v1zero
		beqz $t0, check
		addi $s7, $s7, 1
		j loop0
		
	matchnot0:
		lb $t0, ($s0)
		lb $t1, ($s1)
		addi $s0, $s0, 1
		addi $s1, $s1, 1
		beq $s7, $s2, matchfound
		bne $t0, $t1, v1zero
		addi $s7, $s7, 1
		j matchnot0
	
	check:
		bnez $t1, v1zero
		j matchfound
	
	v1zero:
		move $t0, $s7
		li $t1, 0
		j done2
	
	none:
		li $t0, 0
		li $t1, 0
		j done2
		
	matchfound:
		beqz $s7, none
		move $t0, $s7
		li $t1, 1
	done2:
		move $v0, $t0
		move $v1, $t1
		## EPILOGUE ##
		lw $ra, 44($sp)
		lw $s0, 28($sp)
		lw $s1, 24($sp)
		lw $s2, 20($sp)
		lw $s3, 16($sp)
		lw $s4, 12($sp)
		lw $s5, 8($sp)
		lw $s6, 4($sp)
		lw $s7, 0($sp)
		addi $sp, $sp, 48
    		jr $ra


morse2Key:
    # $a0 = address of morsecode
    # $a1 = address of keymap str
    # $a2 = address of secrekey
    	## PROLOGUE ##
    	addi $sp, $sp, -48
	sw $ra, 44($sp)
	sw $a0, 40($sp)
	sw $a1, 36($sp)
	sw $a2, 32($sp)
	
	sw $s0, 28($sp)
	sw $s1, 24($sp)
	sw $s2, 20($sp)
	sw $s3, 16($sp)
	sw $s4, 12($sp)
	sw $s5, 8($sp)
	sw $s6, 4($sp)
	sw $s7, 0($sp)
	##
	li $s7, 0
	li $s5, 26 # max char in secretkey
	move $s1, $a1
	loopkeymap:
		beq $s7, $s5, noindex
		lw $a0, 40($sp)
		move $a1, $s1
    		li $a2, 3
    		jal strNcmp
    		lw $ra, 44($sp)
    		addi $s1, $s1, 3 # move 3 bytes
    		bnez $v1, foundindex
    		addi $s7, $s7, 1
    		j loopkeymap
    	
    	foundindex:
    		lw $s2, 32($sp)
    		add $s2, $s7, $s2 # address of secretkey[index]
    		lb $v0, ($s2)
    		j done3
    		
    	noindex:
    		li $v0, 0xFFFF	
    	
    done3:
		## EPILOGUE ##
		lw $ra, 44($sp)
		lw $s0, 28($sp)
		lw $s1, 24($sp)
		lw $s2, 20($sp)
		lw $s3, 16($sp)
		lw $s4, 12($sp)
		lw $s5, 8($sp)
		lw $s6, 4($sp)
		lw $s7, 0($sp)
		addi $sp, $sp, 48
    		jr $ra
    


encrypt:
    # $a0 = address of plaintext to be encrypted
    # $a1 = address of phrase to be used to encrpt
    # $a2 = address of morse code array
    # $a3 = address of keymap 
    	
    ## PROLOGUE ##
    	addi $sp, $sp, -52
	sw $ra, 48($sp)
	sw $a0, 44($sp)
	sw $a1, 40($sp)
	sw $a2, 36($sp)
	sw $a3, 32($sp)
	
	sw $s0, 28($sp)
	sw $s1, 24($sp)
	sw $s2, 20($sp)
	sw $s3, 16($sp)
	sw $s4, 12($sp)
	sw $s5, 8($sp)
	sw $s6, 4($sp)
	sw $s7, 0($sp)
	######
	move $s0, $a1
	la $s2, secretkeytxt # secretkey
	la $s1, morsecodetxt
	li $t0, 0
	li $s7, 26

	# PLAINTEXT TO MORSE
	# $a0 = plaintext str address to be converted
	# $a1 = morsecodetext address to store
	# $a2 = size of morsecodetxt
	# $a3 = morsecode array of morse code addresses
	move $a1, $s1
	la $a2, size
	lw $a2, ($a2) # 100
	lw $a3, 36($sp) # morsecode array address
	jal toMorse # returns morsecode address in $a1
	lw $ra 48($sp)
	
	# PHRASE TO SECRETKEY 
	# $a0 = address of message str
    	# $a1 = address to store secret key
	lw $a0, 40($sp)
	move $a1, $s2
	jal createKey
	lw $ra 48($sp)
	
	
	# MORSE2KEY
	# $a0 = address of morsecode
   	# $a1 = address of keymap str
   	# $a2 = address of secrekey
   	li $s6, 0xFFFF
   	loopecpt:
   	move $a0, $s1
   	lw $a1, 32($sp)
   	lb $t0, ($a0)
   	beqz $t0, encrypted
   	move $a2, $s2
   	jal morse2Key
   	lw $ra, 48($sp)
   	beq $v0, $s6, encrypted
   	move $a0, $v0
   	li $v0, 11
   	syscall
   	addi $s1, $s1, 3
   	j loopecpt
   	
	encrypted:
		li $v0, 4
		la $a0, newline
		syscall
		## EPILOGUE ##
		lw $ra, 48($sp)
		lw $s0, 28($sp)
		lw $s1, 24($sp)
		lw $s2, 20($sp)
		lw $s3, 16($sp)
		lw $s4, 12($sp)
		lw $s5, 8($sp)
		lw $s6, 4($sp)
		lw $s7, 0($sp)
		addi $sp, $sp, 52
    		jr $ra


