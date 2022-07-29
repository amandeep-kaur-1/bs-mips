#Data
.data 
data: .space 100 
dataSorted: .space 100

promptForSize: .asciiz "No of Element upto 25: "
promptForElement: .asciiz "Enter Element: \n""
str3: .asciiz "Enter search Element: "
strYes: .asciiz "Element Found in the list"
strNo: .asciiz "Element NOT found in list."


.text 
#Main Program
main: 
	addi $sp, $sp -8
	sw $ra, 0($sp)
	li $v0, 4  
	la $a0, promptForSize 
	syscall
	
	#Get List Size
	li $v0, 5
	syscall
	move $s0, $v0
	move $t0, $0
	la $s1, data
loopForElements:
	li $v0, 4 
	la $a0, promptForElement 
	syscall 
	sll $t1, $t0, 2
	add $t1, $t1, $s1
	
	#Get Single Integer
	li $v0, 5	
	syscall
	sw $v0, 0($t1)
	addi $t0, $t0, 1
	bne $t0, $s0, loopForElements
	
	
	move $a0, $s1
	move $a1, $s0	
	jal sortList
	sw $v0, 4($sp)
	
	li $v0, 4 
	la $a0, str3 
	syscall 
	
	#Get Search Element
	li $v0, 5
	syscall
	
	#Do binary Search
	move $a2, $v0
	lw $a0, 4($sp)
	jal binarySearch
	
	beq $v0, $0, elementNotFound
	li $v0, 4 
	la $a0, strYes 
	syscall 
	j end
	
elementNotFound:
	li $v0, 4 
	la $a0, strNo 
	syscall 
end:
	lw $ra, 0($sp)
	addi $sp, $sp 8
	li $v0, 10 
	syscall
	
	

#Insertion sort
#sortList takes in a list and it size as arguments. 
sortList:
	addi $sp, $sp, -32
	sw $ra, 8($sp)
	sw $s0, 12($sp)
	sw $s1, 16($sp)
	sw $s2, 20($sp)
	sw $s3, 24($sp)
	sw $s4, 28($sp) 
	
	move $s0, $s1 # original array address
	move $s1, $a1 # array size
	addi $s2, $zero, 1 #i = 1
	
		arraycp:
		la $t0, data
		la $t1, dataSorted
		addi $t6, $t6, 0 # iterator
	
		arraycploop:
		#addi $t7, $t6, 1 # iterator is done when one less than size
		beq $s1, $t6, arraycpend
		
		lw $t2, ($t0)
		sw $t2, ($t1)
		
		#iterates pointers and iterator
		addi $t0, $t0, 4 
		addi $t1, $t1, 4
		addi $t6, $t6, 1
		
		j arraycploop

		arraycpend:
		la $t1, dataSorted
		move $s0, $t1
	
	
	iloop:
	beq $s2, $s1, arrayEnd # if i = arraySize then end
	sll $t2, $s2, 2 #offset
	add $t3, $s0, $t2 #Add offset
	lw $s3, ($t3)
	addi $s4, $s2, -1 #Decrement j
	
		jloop:		
		bltz $s4, jindexend # if j is less then 0
		move $a0, $s3 
		la $t0, ($s0) 
		sll $t2, $s4, 2
		add $t3, $t0, $t2 # t3 = array[j]
		lw $a1, ($t3)
		jal isLessThen 
		
		move $t0, $v0
		beq $t0, $zero, jindexend #End

		# array[j+1] = array[j];
		la $t0, ($s0)
		sll $t2, $s4, 2 
		add $t3, $t0, $t2
		lw $t4, 0($t3) # t4 = array[j]

		addi $t2, $s4, 1 # t2 = j + 1
		sll $t3, $t2, 2
		add $t1, $t3, $s0 # address of array[j+1]
		sw $t4, 0($t1) # array[j+1] = array[j]
		addi $s4, $s4, -1 # j--
		j jloop
		
		jindexend:
		move $t0, $s4
		addi $t0, $t0, 1
		sll $t2, $t0, 2
		add $t1, $s0, $t2
		sw $s3, ($t1)
		
		#i++
		addi $s2, $s2, 1 
		j iloop
	arrayEnd:
	move $a1, $s1
	
	lw $ra, 8($sp)
	lw $s0, 12($sp)
	lw $s1, 16($sp)
	lw $s2, 20($sp)
	lw $s3, 24($sp)
	lw $s4, 28($sp)
	addi $sp, $sp, 32

	#return Sorted Data
	la $v0, dataSorted 
	jr $ra

#return True if less else false
isLessThen: 
	move $t0, $a0 
	move $t1, $a1

	loopElements:	
	blt $t0, $t1, ifLessThen 
	bge $t0, $t1, ifGreaterThen
	j loopElements
	
	stringend:
	beq $t2, $zero, ifLessThen
	j ifGreaterThen
	
	ifLessThen: # returns true
	li $v0, 1
	j isLessThenEnd	
	
	ifGreaterThen: # returns false
	li $v0, 0
	j isLessThenEnd

	isLessThenEnd:
	jr $ra
	
	
#Recursive Binary search Algorithm
binarySearch:
	move $s0, $a0 # address sorted list
	move $s1, $a1 # size/right
	move $s2, $a2 # search key
	move $s3, $a3 # left
	li $s5, 0 # mid
	
	addi $s1, $s1, -1 # size/right
	
	#If greater
	bgt $s3, $s1, rightcheck
	goBack:
	blt $s1, $s3, returnFalse 
	
	# mid Index = l + (r - l)/2
	sub $t0, $s1, $s3
	div $t0, $t0, 2
	add $s5, $s3, $t0
	
	# t1 = array[mid]
	sll $t1, $s5, 2
	add $t2, $s0, $t1
	lw $t1, ($t2)
	
	beq $t1, $s2, returnTrue
	

	li $t4, 0
	li $t5, 0
	slti $t4, $a3, 1
	slti $t5, $a1, 1
	
	add $t4, $t4, $t5
	li $t5, 2
	beq $t4, $t5, returnFalse
	
	bgt $t1, $s2, greaterThen # jumps to greater than if t0 > t1
	blt $t1, $s2, lessThen # jumps to less than if t0 < t1

	greaterThen:
	sub $a1, $s5, $s3
	j binarySearch
	
	lessThen:
	addi $a3, $s5, 1
	j binarySearch
	
	returnTrue:
	li $v0, 1
	jr $ra
	returnFalse:
	li $v0, 0
	jr $ra

	rightcheck:
		sll $t6, $s1, 2
		add $t6, $s0, $t6
		lw $t7, ($t6)
		beq $a2, $t7, returnTrue
		
	j goBack