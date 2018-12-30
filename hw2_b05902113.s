.data
	input1:	
		.word	0
	input2:	
		.word	0
	operator:	
		.word	0
	output:	
		.word	0

	file_in:
		.asciiz	"/Users/chenhongsheng/ca_hw2_code/input.txt"
	file_out:
		.asciiz	"/Users/chenhongsheng/ca_hw2_code/output.txt"

	output_ascii:	
		.byte	'X', 'X', 'X', 'X'

.text
	main:
	
	#open file
	li $v0, 13
	la $a0, file_in
	li $a1, 0x0000
	li $a2, 0
	syscall
	move $s0, $v0	# $s0 is the file_in fd
	#read input
	li $v0, 14
	move $a0, $s0
	la $a1, input1
	li $a2, 2
	syscall

	li $v0, 14
	move $a0, $s0
	la $a1, operator
	li $a2, 1
	syscall

	li $v0, 14
	move $a0, $s0
	la $a1, input2
	li $a2, 2
	syscall


	
	#do atoi    s1 = input1 as integer , s2 = input2 as integer  s3 = operator in ASCII
	la	$a0, input1		
	bal	atoi			 
	move	$s1, $v0	# $s1 <= atoi(input1)

	la	$a0, input2		
	bal	atoi			 
	move	$s2, $v0	# $s2 <= atoi(input2)

	lw	$s3, operator	# $s3 <= operator

	

#STEP4 integer operations     '+' = 43   ,    '*' = 42 ,  '-' = 45 ,  '/' = 47
	addi $t1, $zero , 43
	beq $s3,$t1, addition 
	addi $t1, $zero , 45
	beq $s3,$t1, substract
	addi $t1, $zero , 42
	beq $s3,$t1, multiply
	addi $t1, $zero , 47
	beq $s3,$t1, division  
	beq $zero, $zero, error




	

addition:
	add $s4, $s1, $s2
	li $v0, 1
	move $a0, $s4
	syscall
	
	j result

substract:
	sub $s4, $s1, $s2
	li $v0, 1
	move $a0, $s4
	syscall

	j result
multiply:
	mult $s1, $s2
	mflo $s4

	li $v0, 1
	move $a0, $s4
	syscall

	j result
division:
	beq $s2, $zero, error
	div $s1, $s2
	mflo $s4

	li $v0, 1
	move $a0, $s4
	syscall
	
	j result

error:
	la $t0, output_ascii 
	addi $t1, $zero, 4
	addi $t2, $zero, 'X'
.error_loop:
	
	sb $t2, 0($t0)
	addi $t0, $t0, 1
	addi $t1, $t1, -1
	beq $t1, $zero, ret
	beq $zero, $zero, .error_loop
##STEP5: turn the integer into pritable char
result:
	# sw $s4, output???
	move $a0, $s4
	bal itoa

	j ret


itoa: # $a0 = input integer    ,      $v0 = output ascii
	la $t0, output_ascii   #  t0 is output pointer.    
	addi $t1, $zero, 3       #  t1 is the index of output's highest bit
	addi $t2, $zero, 1
	addi $t4, $zero, 10		 #. t4 is contant 10
	add $t5, $zero, $t1      #  t5 stores t1 
	ble $t1, $zero, .loop 
.ten_power:	
	sll $t3, $t2, 1     # t3 = t2 << 1
	sll $t2, $t2, 3 	# t2 = t2 << 3
	add $t2, $t2, $t3 	# t2 *= 10 
	add $t1, $t1, -1
	bne $t1, $zero, .ten_power
.loop:
	div $a0, $t2
	mflo $t1	# $a0/$t2 , the bit we store in output
	addi $t1, $t1, '0'
	sb $t1, 0($t0)
	addi $t0, $t0, 1
	mfhi $a0   # $a0 is the remainder
	div $t2, $t4
	mflo $t2
	add $t5, $t5, -1
	blt $t5, $zero, .out      
	beq $zero, $zero, .loop



#STEP6: write result (output_ascii) to file_out
# ($s4 = fd_out)
ret:
	li	$v0, 13			# 13 = open file
	la	$a0, file_out	# $a2 <= filepath
	li	$a1, 0x41		# $a1 <= flags = 0x4301 for Windows, 0x41 for Linux
	li	$a2, 0x1a4		# $a2 <= mode = 0
	syscall				# $v0 <= $s0 = fd_out
	move	$s4, $v0	# store fd_out in $s4

	li	$v0, 15			# 15 = write file
	move	$a0, $s4	# $a0 <= $s4 = fd_out
	la	$a1, output_ascii
	li	$a2, 4		
	syscall				# $v0 <= $s0 = fd


	li	$v0, 16			# 16 = close file
	move	$a0, $s0	# $a0 <= $s0 = fd_in
	syscall				# close file

	li	$v0, 16			# 16 = close file
	move	$a0, $s4	# $a0 <= $s4 = fd_out
	syscall				# close file

	li $v0, 10 
	syscall

atoi: #   $a0 = the address of input ascii. ,   $vo = output integer

    	or      $v0, $zero, $zero   	# num = 0
   		or      $t1, $zero, $zero   	# isNegative = false
    	lb      $t0, 0($a0)
    	bne     $t0, '+', .isp      	# consume a positive symbol
    	addi    $a0, $a0, 1
.isp:
    	lb      $t0, 0($a0)
    	bne     $t0, '-', .num
    	addi    $t1, $zero, 1       	# isNegative = true
    	addi    $a0, $a0, 1
.num:
    	lb      $t0, 0($a0)
    	slti    $t2, $t0, 58        	# *str <= '9'
    	slti    $t3, $t0, '0'       	# *str < '0'
    	beq     $t2, $zero, .done
    	bne     $t3, $zero, .done
    	sll     $t2, $v0, 1
    	sll     $v0, $v0, 3
    	add     $v0, $v0, $t2       	# num *= 10, using: num = (num << 3) + (num << 1)
    	addi    $t0, $t0, -48
    	add     $v0, $v0, $t0       	# num += (*str - '0')
    	addi    $a0, $a0, 1         	# ++num
    	j   .num
.done:
    	beq     $t1, $zero, .out    	# if (isNegative) num = -num
    	sub     $v0, $zero, $v0		
.out:
    	jr      $ra         			# return
		