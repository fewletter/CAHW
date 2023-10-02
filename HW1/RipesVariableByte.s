.data
testdata:
        .word 0, 128
        .word 0, 1023
        .word 0xffffff, 0xffffffff
        
and1: .word 0x33333333, 0x33333333
and2: .word 0x0f0f0f0f, 0x0f0f0f0f
and3: .word 0x55555555, 0x55555555

.text
main:
    la  t0, testdata
    lw  a0, 0(t0)
    lw  a1, 4(t0)
    jal ra, CLZ
    
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
    slli s4, s2, 30
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
    
    li   a1, 0
    or   a1, a1, s2
    li   a0, 0       # a0,a1 = x >> 32, s2,s3 = x
    add  s3, s3, a1
    
    li   s2, 0
    andi s3, s3, 0x7f
    li   a0, 64
    sub  a0, a0, s3
    ret
    
    
    





    
