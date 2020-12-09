.data
# -9999 marks the end of the list
firstList: .word 8, 3, 6, 10, 13, 7, 4, 5, -9999
maxInt: .word -9999
tree: .space 4
nullVal: .word 0
# other examples for testing your code
secondList: .word 8, 3, 6, 6, 10, 13, 7, 4, 5, -9999
thirdList: .word 8, 3, 6, 10, 13, -9999, 7, 4, 5, -9999

# assertEquals data
failf: .asciiz " failed\n"
passf: .asciiz " passed\n"
buildTest: .asciiz " Build test"
insertTest: .asciiz " Insert test"
findTest: .asciiz " Find test"
asertNumber: .word 0
found: .asciiz "\nNumber is FOUND"
notfound: .asciiz "!Number is NOT FOUND!"
buildMenuText: .asciiz "List is built, you can print the tree through menu - (5)\n\n"
insertMenuText: .asciiz "Inserting process..\nPlease text a number :"
findMenuText: .asciiz "Finding process..\nPlease text a number : "
processEnd: .asciiz "Process is finished\n"
menuPrint: .asciiz  "\n\t\tMENU\t\t
\nFOR TEST CASES : WRITE 1 
\n###CHOICES BELOW ARE JUST ADDITIONAL###
\n### To insert ( choice 3 ), to find ( choice 4 ) or to print ( choice 5 ) TREE MUST BE BUILT. IF TREE IS NOT BUILT IT GIVES ERROR WITH THESE CHOICES###
\nTo build the list : write 2
\nInsert test- to add a value manually, write 3
\nFind test - to find a value, write 4
\nTo print tree: write 5
\nTo exit : write 6\n
Write your choice :"
newline: .asciiz "\n"
space: .asciiz "\n--------------------------------\n"
addressText: .asciiz "address:"
valueText: .asciiz "value:"
leftChildText: .asciiz "leftChild:"
rightChildText: .asciiz "rightChild:"
parentText: .asciiz "parent:"
inorderPrintText: .asciiz "\n\t\tInorder Print Tree\n"
scrollUp: .asciiz "\n----To see result, please scroll up----"
.text
main:

    # The test code assumes your root node's address is stored at $s0 and at tree argument at all times
    # Although it's not needed, you can:
    #         - modify the test cases if you must
    #         - add code between test cases
    #

    la $s0, tree
    lw $s2, maxInt
    
    j menu


testcase:

    la $a0, secondList
    jal build

   
    lw $t0, 4($s0) # address of the left child of the root
    lw $a0, 0($t0) # real value of the left child of the root
    li $a1, 3 # expected value of the left child of the root
    la $a2, buildTest # the name of the test
    # if left child != 3 then print failed 
    jal assertEquals

    # check insert procedure
    li $a0, 11 # new value to be inserted
    move $a1, $s0 # address of the root
    jal insert
    # no need to reload 11 to $a0
    lw $a1, 0($v0) # value from the returned address
    la $a2, insertTest # the name of the test
    # if returned address's value != 11 print failed 
    jal assertEquals

    # check find procedure
    li $a0, 11 # search value
    move $a1, $s0 # adress of the root
    jal find 
    # no need to reload 11 to $a0
    lw $a1, 0($v1) # value from the found adress
    la $a2, findTest # the name of the test
    # if returned address's value != 11 print failed 
    jal assertEquals

    # check find procedure 2
    # 44 should not be on the list
    # v0 should return 1
    li $a0, 44 # search value
    move $a1, $s0 # adress of the root
    jal find
    move $a0, $v0 # result of the search
    li $a1, 1 # expected result of the search
    la $a2, findTest # the name of the test
    # if returned value of $v0 != 0 print failed
    jal assertEquals

    move $a0, $s0
    jal print # print tree for visual inspection


assertEquals:
    move $t2, $a0
    # increment count of total assertions.
    la $t0, asertNumber
    lw $t1, 0($t0)
    addi $t1, $t1, 1
    sw $t1, 0($t0) 

    # print the test number
    add $a0, $t1, $zero
    li $v0, 1
    syscall
    
    # print the test name
    move $a0, $a2
    li $v0, 4
    syscall

    # print passed or failed.
    beq $t2, $a1, passed
    la $a0, failf
    li $v0, 4
    syscall
    j $ra

passed:
    la $a0, passf
    li $v0, 4
    syscall
    j $ra

failed:
    la $a0, failf
    li $v0, 4
    syscall
    j $ra

#menu-start
menu:
    la $a0, menuPrint
    li $v0, 4
    syscall
    
    li $v0, 5 # syscall 5 == read_int.
    syscall
    move $a0, $v0 # choice

    beq $a0,1,testcase
    beq $a0,2,goBuild
    beq $a0,3,goInsert
    beq $a0,4,goFind
    beq $a0,5,print
    beq $a0,6,exit
    b menu
#
getValue:
    li $v0, 5 # syscall 5 == read_int.
    syscall
    move $a0, $v0 # value
    jr $ra
#
goBuild:
    la $a0, buildMenuText
    li $v0, 4
    syscall
    jal newLine
    la $a0, thirdList
    jal build
    j menu
#
goInsert:
   
    la $a0, insertMenuText
    li $v0, 4
    syscall
    jal getValue
    move $a1,$s0
    jal insert
    la $a0, processEnd
    li $v0, 4
    syscall
    j menu
#
goFind:
    la $a0, findMenuText
    li $v0, 4
    syscall
    jal getValue
    move $a1,$s0
    jal find
    la $a0, processEnd
    li $v0, 4
    syscall
    j menu
    
#menu-end



#build-start
build:

    addiu $sp,$sp,-8 # reserve 8 bytes of stack
    sw $ra,4($sp) # save registers
    sw $a0,0($sp) # save $a0 (list)

    move $t1, $a0 # move starting address of the list to $t1

    #Set first element as the root and create a node for root
    lw $t2, 0($t1) # $t2 = value
    addi $t1, $t1, 4     # increment the list's starting adress to access to next element
    li $t3, 0 # $t3 = left /default = 0/
    li $t4,  0 # $t4 = right /default = 0/
    
    li $a0, 16 # need 16 bytes for the new node.
    li $v0, 9 # sbrk syscall 9.
    syscall
    move $s3, $v0 #s3 = adress for the node

    sw $t2, 0($s3) # node->value = value
    sw $t3, 4($s3) # node->left = left
    sw $t4, 8($s3) # node->right = right
    sw $s0, 12($s3)

    move $v0, $s3 # put return node into v0.
    move $s0, $v0 # save the node.
    
    jal get_list #get the elements of list and create a tree.
    jr $ra
   
#build-end

#get_list-start /helper function of build function/
get_list:

    # create the root node
    lw $s1, 0($t1)  #load element of the list
    beq $s1, $s2, restore_build_stack_val # if terminated, print

    #insert (value, tree);
    move $a0, $s1 # value= $s1
    move $a1, $s0 # tree = $s0
    jal insert # go to insert function.
    addi $t1, $t1, 4     # increment the list's starting adress to access to next element
    j get_list
    jr $ra   
#get_list-end /helper function of build function/

restore_build_stack_val:
    lw $ra, 4($sp) # restore the Return Address.
    lw $a0, 0($sp) # restore $a0.
    addiu $sp, $sp, 8 # restore the Stack Pointer.
    jr $ra

#insert-start
#@param : a0 = value, a1 = root
insert:
    addiu $sp, $sp, -20
    sw $ra, 16($sp)
    sw $a0, 12($sp)
    sw $s0, 8($sp)
    sw $s3, 4($sp)
    sw $s4, 0($sp)

    move $t5, $a0 # $t5 = value 
    move $t6, $a1 # $t6 = tree

    # create new node 

    move $t2, $t5 # $t2 = val
    li $t3,  0 # $t3 = left /default = 0/
    li $t4,  0 # $t4 = right /default = 0/

    li $a0, 16 # need 16 bytes for the new node.
    li $v0, 9 # sbrk is syscall 9.
    syscall
    move $s3, $v0 #s3 = address for the node

    sw $t2, 0($s3) # node->value = value
    sw $t3, 4($s3) # node->left = left
    sw $t4, 8($s3) # node->right = right
    sw $s0, 12($s3) #temporarly assing -9999 as the parent

    move $v0, $s3 # put return value into v0.
    move $s0, $v0 # holds the node.

    jal findPlace # find appropriate place to insert $s0 (node)
    



#HELPER FUNCTIONS FOR INSERTING BELOW :



#If value is smaller than root value, go to left child of the root and make left child the new root. 
#If value is greater than root value, go to right child of the root and make right child the new root. 
# Loop until find a place
# If place is found, insert the value to the 4(root)-if it is left- or 8(root)-if it is right-
findPlace:
    lw $s3, 0($t6) # root_val = root->val;
    blt $t5, $s3, leftChild # if (val < s3) goto leftChild;
    b rightChild # go to rightChild;
#
#
leftChild:
    lw $s4, 4($t6) # get leftChild of the root : root->left;
    bnez $s4, goLeft #if leftChild of $t6 is not equal to 0, go left child of left child of $t6
    #else :
    sw $s0, 4($t6) # assign the left child to the 4($parent) = define the left child of parent
    sw $t6, 12($s0) # assign the parent to the 12($node)
    b restore_stack_val # go to restore_stack_val;
#
#
goLeft:
    move $t6, $s4 # root = leftChild;
    b findPlace # go to findPlace;
#
#
rightChild:
    lw $s4, 8($t6)# get rightChild of the root : root->right;
    bnez $s4, goRight #if rightChild of $t6 is not equal to 0, go right child of right child of $t6
    #else:
    sw $s0, 8($t6) # assign the right child to the 8($parent) = define the right child of parent
    sw $t6, 12($s0)  # assign the parent to the 12($node)
    b restore_stack_val # go to restore_stack_val;
#
#
goRight:
    move $t6, $s4 # root = rightChild;
    b findPlace # go to findPlace;
#
#
restore_stack_val:
    lw $ra, 16($sp)
    lw $a0, 12($sp) # restore the Return Address.
    lw $s0, 8($sp) # restore $s0.
    lw $s3, 4($sp) # restore $s3.
    lw $s4, 0($sp) # restore $s4.
    addiu $sp, $sp, 20 # restore the Stack Pointer.
    jr $ra # return.
#

#insert-end




#print-start
print:
    la $a0, inorderPrintText
    li $v0, 4
    syscall

    lw $a0, 4($s0) # print left child of root.
    jal print_recursive

    jal printNode

    lw $a0, 8($s0) # print right child of root.
    jal print_recursive

    la $a0, scrollUp
    li $v0, 4
    syscall 
    b menu


#print_recursive /helper function for print/
#If s0(root) is not equal to 0 :
#go to left child of root ( 4($s0) ), make it new  root and do recursion
# print the root value
#go to right child of root ( 8($s0) ), make it new root and do recursion
#@param : a0 = subtree - gotten from print function
print_recursive:
    addiu $sp, $sp, -8
    sw $ra, 4($sp)
    sw $s0, 0($sp)

    move $s0, $a0 # $s0 = root of subtree
    beqz $s0, restore_print_stack_val # if root == 0, halt and restore values in the stack

    lw $a0, 4($s0) # recurse left.
    jal print_recursive
    
   jal printNode

    lw $a0, 8($s0) # recurse right.
    jal print_recursive


#

restore_print_stack_val: 
    lw $ra, 4($sp) # restore the Return Address.
    lw $s0, 0($sp) # restore $s0.
    addu $sp, $sp, 8 # restore the Stack Pointer.
    jr $ra # return.

#print-end


#find-start
find:
    addiu $sp, $sp, -20
    sw $ra, 16($sp)
    sw $a0, 12($sp)
    sw $s0, 8($sp)
    sw $s3, 4($sp)
    sw $s4, 0($sp)
    
    move $t1, $a0
    move $s0, $a1
    lw $a0, 0($s0)
    move $t6, $a0 # $a0 = root of tree
    beq $s0, $t1,printFind  # if root == value, print value and restore values in the stack
    jal search #else go to search


#BELOW HELPER FUNCTIONS FOR FIND FUNCTION

#
search:
    beq $s0, $zero,notFound # If root of subtree is zero, halt.
    lw $s3, 0($s0) # root_val = root->val;
    beq $s3, $t1,printFind   # if root == value, print value and restore values in the stack
    blt $t1, $s3, searchLeft # if (val < root) go to searchLeft;
    b searchRight # else go to searchRight;
#
#
searchLeft:
    lw $s4, 4($s0) # get left child of the root : root->left;
    move $s0, $s4 # root = left child;
    b search # go to findPlace;
    
#
#
searchRight:
    lw $s4, 8($s0)# get rightChild of the root : root->right;
    move $s0, $s4 # root = right child;
    b search # go to findPlace;
#
#
notFound:
    jal newLine
    la $a0, notfound #print not found
    li $v0, 4
    syscall
    jal newLine
    li $v0,1

    lw $ra, 16($sp)
    lw $a0, 12($sp) # restore the Return Address.
    lw $s0, 8($sp) # restore $s0.
    lw $s3, 4($sp) # restore $s3.
    lw $s4, 0($sp) # restore $s4.
    addiu $sp, $sp, 20 # restore the Stack Pointer.
    jr $ra
#
#
printFind:
    la $a0, found #print found
    li $v0, 4
    syscall

    jal printNode

    li $v0,0
    move $v1, $s0

    lw $ra, 16($sp) # restore the Return Address.
    lw $a0, 12($sp)
    lw $s0, 8($sp) # restore $s0.
    lw $s3, 4($sp) # restore $s3.
    lw $s4, 0($sp) # restore $s4.
    addiu $sp, $sp, 20 # restore the Stack Pointer.

  
    jr $ra
#find-end

printNode:

    la $a0, space
    li $v0, 4
    syscall

    la $a0, addressText
    li $v0, 4
    syscall
    la $a0, 0($s0) # print the address of value
    li $v0, 1
    syscall
    la $a0, newline
    li $v0, 4
    syscall

    la $a0, valueText
    li $v0, 4
    syscall
    lw $a0, 0($s0) # print the value
    li $v0, 1
    syscall
    la $a0, newline
    li $v0, 4
    syscall

    la $a0, parentText
    li $v0, 4
    syscall
    lw $t5, 12($s0)
    lw $a0, 0($t5) # print the parent
    li $v0, 1
    syscall
    la $a0, newline
    li $v0, 4
    syscall
    
    la $a0, leftChildText
    li $v0, 4
    syscall
    lw $a0, 4($s0) # print the address of right child
    li $v0, 1
    syscall
    la $a0, newline
    li $v0, 4
    syscall

    la $a0, rightChildText
    li $v0, 4
    syscall
    lw $a0, 8($s0) # print the address of right child
    li $v0, 1
    syscall

    la $a0, space
    li $v0, 4
    syscall
    jr $ra
#################################
newLine:
    la $a0, newline
    li $v0, 4
    syscall
    jr $ra


exit:
    li $v0, 10 # 10 is the exit syscall.
    syscall
    ## end of
