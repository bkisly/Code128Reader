#define START_CODE 1692
#define STOP_CODE 1594

#include <stdio.h>
#include "image.h"

extern unsigned char *addressAfterQuiet(unsigned char *beginAddress, unsigned char *endAddress);
extern uint8_t getNarrowestBar(unsigned char *beginAddress, unsigned char *endAddress);
extern unsigned int readSequence(unsigned char *beginAddres, uint8_t barLength);
extern int8_t convertSequence(unsigned int sequence);

void printSequences(unsigned char *beginAddress, unsigned char *endAddress)
{
    int stopReached = 0;
    unsigned char *addrAfterQuiet = addressAfterQuiet(beginAddress, endAddress);
    uint8_t narrowestBarLenght = getNarrowestBar(beginAddress, endAddress);

    while(!stopReached)
    {
        unsigned int sequence = readSequence(addrAfterQuiet, narrowestBarLenght);
        unsigned int convertedSequence = convertSequence(sequence);

        if(sequence != START_CODE && sequence != STOP_CODE)
        {
            printf("Sequence value: %i, decoded value: ", sequence);

            if(convertedSequence < 10) printf("0");

            printf("%i\n", convertedSequence);
        }
        else if(sequence == STOP_CODE)
            stopReached = 1;

        addrAfterQuiet += 3 * 11 * narrowestBarLenght;
    }
}

int main()
{
    ImageInfo* imgInfo = readBmp("cbarcode.bmp");
    unsigned char *beginAddress = imgInfo->pImg + (imgInfo->height / 2) * imgInfo->line_bytes;
    unsigned char *endAddress = beginAddress + imgInfo->width * 3;

    printSequences(beginAddress, endAddress);

    freeImage(imgInfo);
    return 0;
}