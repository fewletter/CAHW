#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

uint16_t count_leading_zeros(uint64_t x)
{
    x |= (x >> 1);
    x |= (x >> 2);
    x |= (x >> 4);
    x |= (x >> 8);
    x |= (x >> 16);
    x |= (x >> 32);

    /* count ones (population count) */
    x -= ((x >> 1) & 0x5555555555555555 /* Fill this! */ );
    x = ((x >> 2) & 0x3333333333333333) + (x & 0x3333333333333333 /* Fill this! */);
    x = ((x >> 4) + x) & 0x0f0f0f0f0f0f0f0f;
    x += (x >> 8);
    x += (x >> 16);
    x += (x >> 32);

    return (64 - (x & 0x7f));
}

void encodeVariableByte(uint64_t value, uint32_t *encodebytes, int len) {
    uint32_t bitmask1 = 0x7f;
    uint32_t bitmask2 = 0x80;
    for (int i = 0; i < len; i++) {
        if (i % 4 == 0) {
            bitmask1 = 0x7f;
            bitmask2 = 0x80;
        }
        encodebytes[i/4] |= i/4 == 0 ? (value & bitmask1) << i : (((value >> 28) & bitmask1) << (i % 4));
        encodebytes[i/4] = i == 0 ? encodebytes[i/4] : (encodebytes[i/4] | bitmask2);
        bitmask1 <<= 7;
        bitmask2 <<= 8;
    }
}

int main() {
    uint64_t testdata[3] = { 128, 0xfffffff, 0xffffffffffffff};
    int len1 = (63 - count_leading_zeros(testdata[0])) / 7 + 1;
    printf("%d\n", len1);
    uint32_t encodedData1[1] = {0}; 

    int len2 = (63 - count_leading_zeros(testdata[1])) / 7 + 1;
    uint32_t encodedData2[1] = {0};
    
    int len3 = (63 - count_leading_zeros(testdata[2])) / 7 + 1;
    uint32_t encodedData3[2] = {0, 0};

    encodeVariableByte(testdata[0], encodedData1, len1);
    encodeVariableByte(testdata[1], encodedData2, len2);
    encodeVariableByte(testdata[2], encodedData3, len3);

    printf("Encoded Bytes: ");
    for (int i = 0; i < 1; ++i) {
        printf("%x ", encodedData1[i]);
    }
    printf("\n");
    printf("Encoded Bytes: ");
    for (int i = 0; i < 1; ++i) {
        printf("%x ", encodedData2[i]);
    }
    printf("\n");
    printf("Encoded Bytes: ");
    for (int i = 0; i < 2; ++i) {
        printf("%x ", encodedData3[i]);
    }
    printf("\n");


    return 0;
}