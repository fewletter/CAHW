.data
testdata:
        .word 0, 128
        .word 0, 0xfffffff
        .word 0xffffff, 0xffffffff
        
and1: .word 0x33333333, 0x33333333
and2: .word 0x0f0f0f0f, 0x0f0f0f0f
and3: .word 0x55555555, 0x55555555
\n: .string "\n"
EncodedBytes: .string "Encoded Bytes: "

encodedData1:
    .word 0
encodedData2:
    .word 0
encodedData3:
    .word 0, 0

.text
main:
    la   t6, testdata
    lw   a0, 0(t6)
    lw   a1, 4(t6)
    jal  ra, CLZ
    li   t1, 63
    sub  a0, t1, a0
    li   t1, 7
    div  a0, a0, t1
    addi a0, a0, 1   #a0 = len1
    lw   a1, 4(t6)   #a1,a2 = value  
    lw   a2, 0(t6)
    la   t5, encodedData1  # uint32_t encodedData1[1] = {0}
    lw   a3, 0(t5)
    jal  ra, encodeVariableByte
    mv   t6, a3
    jal  ra, printHEX
    
    la   t6, testdata
    lw   a0, 8(t6)
    lw   a1, 12(t6)
    jal  ra, CLZ
    li   t1, 63
    sub  a0, t1, a0
    li   t1, 7
    div  a0, a0, t1
    addi a0, a0, 1   #a0 = len2
    lw   a1, 12(t6)   #a1,a2 = value  
    lw   a2, 8(t6)
    la   t5, encodedData2  # uint32_t encodedData2[1] = {0}
    lw   a3, 0(t5)
    jal  ra, encodeVariableByte
    mv   t6, a3
    jal  ra, printHEX
    
    la   t6, testdata
    lw   a0, 16(t6)
    lw   a1, 20(t6)
    jal  ra, CLZ
    li   t1, 63
    sub  a0, t1, a0
    li   t1, 7
    div  a0, a0, t1
    addi a0, a0, 1   #a0 = len3
    lw   a1, 20(t6)   #a1,a2 = value  
    lw   a2, 16(t6)
    la   t5, encodedData3  # uint32_t encodedData3[2] = {0,0}
    lw   a3, 0(t5)
    lw   a4, 4(t5)
    jal  ra, encodeVariableByte
    mv   t6, a3
    jal  ra, printHEX
    mv   t6, a4
    jal  ra, printHEX
  
    li   a7, 10
    ecall

printHEX:
    la   a0, EncodedBytes
    li   a7, 4
    ecall
    mv   a0, t6   # return in register a0
    li   a7, 34   
    ecall
    la   a0, \n
    li   a7, 4
    ecall
    ret
    
encodeVariableByte:
    li   t0, 0x7f   # bitmask1
    li   t1, 0x80   # bitmask2
    li   t2, 0      # i = 0
    li   t3, 4
    li   t5, 0
    j    first_register
    
first_register:
    div  a5, t2, t3
    bne  a5, t5, reset_bitmask
    and  t4, a1, t0 # value & bitmask1
    sll  t4, t4, t2 # (value & bitmask1) << i
    or   a3, a3, t4
    bne  t2, t5, not_firstbyte
    slli t0, t0, 7
    slli t1, t1, 8
    addi t2, t2, 1
    j    first_register

not_firstbyte:
    or   a3, a3, t1
    slli t0, t0, 7
    slli t1, t1, 8
    addi t2, t2, 1
    beq  t2, a0, exit
    j    first_register

exit:
    jr   ra
    
second_register:
    and  t4, a2, t0 # (value >> 28) & bitmask1
    andi s0, t2, 0x3 # i % 4
    sll  t4, t4, s0 # ((value >> 28) & bitmask1) << (i % 4)
    or   a4, a4, t4
    or   a4, a4, t1
    slli t0, t0, 7
    slli t1, t1, 8
    addi t2, t2, 1
    beq  t2, a0, exit
    j    second_register
    
reset_bitmask:
    li   t0, 0x7f   # bitmask1
    li   t1, 0x80   # bitmask2
    slli a2, a2, 4
    srli s1, a1, 28
    or   a2, a2, s1 
    j    second_register

    
CLZ:
    # a0 presents higher bit, a1 presents lower bit
    # a0 store in s2, a1 store s3
    
    addi s2, a0, 0
    addi s3, a1, 0
    
    # x |= x >> 1; 
    srli a1, s3, 1
    slli s4, s2, 31
    or   a1, a1, s4
    srli a0, s2, 1   # a0,a1 = x >> 1, s2,s3 = x
    or   s3, a1, s3  
    or   s2, a0, s2  # x |= (x >> 1)
    
    # x |= x >> 2; 
    srli a1, s3, 2
    slli s4, s2, 30
    or   a1, a1, s4
    srli a0, s2, 2   # a0,a1 = x >> 2, s2,s3 = x
    or   s3, a1, s3  
    or   s2, a0, s2  # x |= (x >> 2)
    
    # x |= x >> 4; 
    srli a1, s3, 4
    slli s4, s2, 26
    or   a1, a1, s4
    srli a0, s2, 4   # a0,a1 = x >> 4, s2,s3 = x
    or   s3, a1, s3  
    or   s2, a0, s2  # x |= (x >> 4)
    
    # x |= x >> 8; 
    srli a1, s3, 8
    slli s4, s2, 24
    or   a1, a1, s4
    srli a0, s2, 8   # a0,a1 = x >> 8, s2,s3 = x
    or   s3, a1, s3  
    or   s2, a0, s2  # x |= (x >> 8)
    
    # x |= x >> 16; 
    srli a1, s3, 16
    slli s4, s2, 16
    or   a1, a1, s4
    srli a0, s2, 16  # a0,a1 = x >> 16, s2,s3 = x
    or   s3, a1, s3  
    or   s2, a0, s2  # x |= (x >> 16)
    
    # x |= x >> 32; 
    li   a1, 0
    or   a1, a1, s2
    li   a0, 0       # a0,a1 = x >> 16, s2,s3 = x
    or   s3, a1, s3   
    or   s2, a0, s2  # x |= (x >> 32)
    
    # load 0x5555555555555555
    la  t0, and3
    lw  t1, 0(t0)
    lw  t2, 4(t0)
    
    srli a1, s3, 1
    slli s4, s2, 31
    or   a1, a1, s4
    srli a0, s2, 1   # a0,a1 = x >> 1, s2,s3 = x
    and  a1, a1, t2
    and  a0, a0, t1
    sub  s3, s3, a1
    sub  s2, s2, a0
    
    # load 0x3333333333333333
    la  t0, and1
    lw  t1, 0(t0)
    lw  t2, 4(t0)
    
    srli a1, s3, 2
    slli s4, s2, 30
    or   a1, a1, s4
    srli a0, s2, 2   # a0,a1 = x >> 2, s2,s3 = x
    and  a1, a1, t2  # lower bit & 0x33333333
    and  a0, a0, t1  # higher bit & 0x33333333
    and  s3, s3, t2  # lower bit & 0x33333333
    and  s2, s2, t1  # higher bit & 0x33333333
    add  s3, s3, a1  # lower bit add
    add  s2, s2, a0  # higher bit add

    # load 0x0f0f0f0f0f0f0f0f
    la  t0, and2
    lw  t1, 0(t0)
    lw  t2, 4(t0)
    
    srli a1, s3, 4
    slli s4, s2, 28
    or   a1, a1, s4
    srli a0, s2, 4   # a0,a1 = x >> 4, s2,s3 = x
    add  s3, s3, a1  # lower bit add
    add  s2, s2, a0  # higher bit add
    and  s3, s3, t2  # lower bit & 0x0f0f0f0f
    and  s2, s2, t1  # higher bit & 0x0f0f0f0f
    
    srli a1, s3, 8
    slli s4, s2, 24
    or   a1, a1, s4
    srli a0, s2, 8   # a0,a1 = x >> 8, s2,s3 = x
    add  s3, s3, a1
    add  s2, s2, a0
    
    srli a1, s3, 16
    slli s4, s2, 16
    or   a1, a1, s4
    srli a0, s2, 16  # a0,a1 = x >> 16, s2,s3 = x
    add  s3, s3, a1
    add  s2, s2, a0
    
    add  s3, s3, s2
    
    andi s3, s3, 0x7f
    li   a0, 64
    sub  a0, a0, s3  # return in register t0
    jr   ra