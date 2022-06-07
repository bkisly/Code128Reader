#define START_CODE 1692
#define STOP_CODE 1594

#include <stdio.h>
#include "image.h"

extern unsigned char *addressAfterQuiet(unsigned char *beginAddress, unsigned char *endAddress);
extern uint8_t getNarrowestBar(unsigned char *beginAddress, unsigned char *endAddress);
extern unsigned int readSequence(unsigned char *beginAddres, uint8_t barLength);

void printSequences(unsigned char *beginAddress, unsigned char *endAddress)
{
    int stopReached = 0;
    unsigned char *addrAfterQuiet = addressAfterQuiet(beginAddress, endAddress);
    uint8_t narrowestBarLenght = getNarrowestBar(beginAddress, endAddress);

    while(!stopReached)
    {
        unsigned int sequence = readSequence(addrAfterQuiet, narrowestBarLenght);

        if(sequence != START_CODE && sequence != STOP_CODE)
            printf("%i\n", sequence);
        else if(sequence == STOP_CODE)
            stopReached = 1;

        addrAfterQuiet += 3 * 11 * narrowestBarLenght;
    }
}

int main()
{
    ImageInfo* imgInfo = readBmp("cbarcode2.bmp");
    unsigned char *beginAddress = imgInfo->pImg + (imgInfo->height / 2) * imgInfo->line_bytes;
    unsigned char *endAddress = beginAddress + imgInfo->width * 3;

    printf("Length of the narrowest bar = %i\n", getNarrowestBar(
        beginAddress, endAddress));
    printf("Begin address = %i, address after quiet = %i\n", beginAddress, addressAfterQuiet(beginAddress, endAddress));

    printf("First sequence = %i\n\n\n\n", readSequence(addressAfterQuiet(beginAddress, endAddress), getNarrowestBar(beginAddress, endAddress)));

    printSequences(beginAddress, endAddress);

    freeImage(imgInfo);
    return 0;
}