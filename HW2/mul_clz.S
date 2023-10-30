.org 0
# Provide program starting address to linker
.global _start
.globl get_cycles

/* newlib system calls */
.set SYSEXIT,  93
.set SYSWRITE, 64
.set SYSPRINTFHEX, 31

.data
    data_1: .word 0x12345678
    data_2: .word 0xffffdddd
    mask_1: .word 0x55555555
    mask_2: .word 0x33333333
    mask_3: .word 0x0f0f0f0f
.text
    
_start:
    lw s0, data_1   #s0 = A
    lw s1, data_2   #s1 = B
    
    mv a0, s0    
    jal ra, CLZ
    mv t5, a0    #A's CLZ ->  t5
    mv a0, s1
    jal ra, CLZ
    mv t6, a0    #B's CLZ ->  t6
    slt t0, t5, t6 # if A's zero less than B's, t0=1
    li a0, 32
    jal ra, get_cycles
    mv  a4, a3
    bne t0, zero, start_mul
    
start_mul:
    #reset
    mv t0, s0      #A ^= B;
    mv s0, s1      #B ^= A;
    mv s1, t0      #A ^= B;
    mv t6, t5
    sub a0, a0, t6
    li t0, 0
    li t1, 0
    li t2, 0    
    li s2, 0        #s2: high 32 of number
    li s3, 0        #s3: low 32 of number
    li s4, 0        #used to check how many bit should shift   

int_mul:
    slt t1, s4, a0
    beq t1, zero, exit
    srl t0, s1, s4
    andi t0, t0, 0x00000001       #check B's rightest bit
    beq t0, zero, skip            #if(rightest bit is zero) jump
    sll s5,s0,s4                  #s0 is A,S5 the low bit i want
    li t2, 32
    sub t2, t2, s4
    srl s6, s0, t2             #s0 is A, S6 the high bit i want
    add s7, s3, s5             #s7 is 32_low + low bit i want

    sltu t3, s7, s3
    mv s3, s7
    beq t3, zero, no_overflow
    # if not jump  -->  overflow
    add s2, s2, s6
    addi s2, s2, 1
    addi s4, s4 ,1

#   Loop unrolling 1

    srl t0, s1, s4
    andi t0, t0, 0x00000001       
    beq t0, zero, skip            
    sll s5,s0,s4                  
    li t2, 32
    sub t2, t2, s4
    srl s6, s0, t2             
    add s7, s3, s5             

    sltu t3, s7, s3
    mv s3, s7
    beq t3, zero, no_overflow
    # if not jump  -->  overflow
    add s2, s2, s6
    addi s2, s2, 1
    addi s4, s4 ,1

#   Loop unrolling 2

    srl t0, s1, s4
    andi t0, t0, 0x00000001       
    beq t0, zero, skip            
    sll s5,s0,s4                  
    li t2, 32
    sub t2, t2, s4
    srl s6, s0, t2             
    add s7, s3, s5             

    sltu t3, s7, s3
    mv s3, s7
    beq t3, zero, no_overflow
    # if not jump  -->  overflow
    add s2, s2, s6
    addi s2, s2, 1
    addi s4, s4 ,1

#   Loop unrolling 3

    srl t0, s1, s4
    andi t0, t0, 0x00000001       
    beq t0, zero, skip            
    sll s5,s0,s4                  
    li t2, 32
    sub t2, t2, s4
    srl s6, s0, t2             
    add s7, s3, s5             

    sltu t3, s7, s3
    mv s3, s7
    beq t3, zero, no_overflow
    # if not jump  -->  overflow
    add s2, s2, s6
    addi s2, s2, 1
    addi s4, s4 ,1

    jal int_mul
    
no_overflow:
    add s2, s2, s6
    jal skip
    
skip:
    addi s4, s4 ,1
    jal int_mul

CLZ:
    #a0: the num(x) you want to count CLZ
    #t0: shifted x
    srli t0, a0, 1    # t0 = x >> 1
    or a0, a0, t0     # x |= x >> 1
    srli t0, a0, 2    # t0 = x >> 2
    or a0, a0, t0     # x |= x >> 2
    srli t0, a0, 4    # t0 = x >> 4
    or a0, a0, t0     # x |= x >> 4
    srli t0, a0, 8    # t0 = x >> 8
    or a0, a0, t0     # x |= x >> 8
    srli t0, a0, 16   # t0 = x >> 16
    or a0, a0, t0     # x |= x >> 16
    #start_mask
    lw t2, mask_1
    srli t0, a0, 1    # t0 = x >> 1
    and t1, t0, t2    # t1 = (x >> 1) & mask1
    sub a0, a0, t1    # x -= ((x >> 1) & mask1)
    lw t2, mask_2     # load mask2 to t2
    srli t0, a0, 2    # t0 = x >> 2
    and t1, t0, t2    # (x >> 2) & mask2
    and a0, a0, t2    # x & mask2
    add a0, t1, a0    # ((x >> 2) & mask2) + (x & mask2)
    srli t0, a0, 4    # t0 = x >> 4
    add a0, a0, t0    # x + (x >> 4)
    lw t2, mask_3      # load mask3 to t2
    and a0, a0, t2    # ((x >> 4) + x) & mask4
    srli t0, a0, 8    # t0 = x >> 8
    add a0, a0, t0    # x += (x >> 8)
    srli t0, a0, 16   # t0 = x >> 16
    add a0, a0, t0    # x += (x >> 16)
    andi t0, a0, 0x3f # t0 = x & 0x3f
    li a0, 32         # a0 = 32
    sub a0, a0, t0    # 32 - (x & 0x3f)
    ret

exit:
    jal ra, get_cycles
    sub a3, a3, a4
    li a0, 1
    mv a1, s2
    mv a2, s3
    li a7, SYSPRINTFHEX
    ecall
    li a0, 1
    mv a1, a3
    li a2, 0
    li a7, 32
    ecall
    li a0, 0
    li a7, SYSEXIT
    ecall

get_cycles:
    csrr a1, cycleh
    csrr a3, cycle
    csrr a2, cycleh
    bne a1, a2, get_cycles
    ret
