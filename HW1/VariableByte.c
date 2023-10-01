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

void encodeVariableByte(uint64_t value, uint8_t *encodebytes, int len) {
    for (int i = 0; i < len; i++)
        encodebytes[i] = i == 0 ? ((value >> (i * 7)) & 0x7F) & 0x7f : ((value >> (i * 7)) & 0x7F) | 0x80;
}

int main() {
    uint64_t testdata[3] = { 128, 0xffffffffffffff, 0xffffffffffffffff}; /*128, 72057594037927935, 18446744073709551615*/
    int len1 = (63 - count_leading_zeros(testdata[0])) / 7 + 1;
    uint8_t encodedData1[len1];

    int len2 = (63 - count_leading_zeros(testdata[1])) / 7 + 1;
    uint8_t encodedData2[len2];
    
    int len3 = (63 - count_leading_zeros(testdata[2])) / 7 + 1;
    uint8_t encodedData3[len3];

    encodeVariableByte(testdata[0], encodedData1, len1);
    encodeVariableByte(testdata[1], encodedData2, len2);
    encodeVariableByte(testdata[2], encodedData3, len3);

    printf("Encoded Bytes: ");
    for (int i = 0; i < len1; ++i) {
        printf("%x ", encodedData1[i]);
    }
    printf("\n");
    printf("Encoded Bytes: ");
    for (int i = 0; i < len2; ++i) {
        printf("%x ", encodedData2[i]);
    }
    printf("\n");
    printf("Encoded Bytes: ");
    for (int i = 0; i < len3; ++i) {
        printf("%x ", encodedData3[i]);
    }
    printf("\n");


    return 0;
}