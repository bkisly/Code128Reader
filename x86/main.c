#define START_CODE 1692
#define STOP_CODE 1594

#include <stdio.h>
#include "image.h"

extern unsigned char *addressAfterQuiet(unsigned char *beginAddress, unsigned char *endAddress);
extern uint8_t getNarrowestBar(unsigned char *beginAddress, unsigned char *endAddress);
extern unsigned int readSequence(unsigned char *beginAddres, uint8_t barLength);
extern int8_t convertSequence(unsigned int sequence);

int printSequences(unsigned char *beginAddress, unsigned char *endAddress)
{
    int stopReached = 0;
    unsigned char *addrAfterQuiet = addressAfterQuiet(beginAddress, endAddress);
    uint8_t narrowestBarLenght = getNarrowestBar(beginAddress, endAddress);
    int distToNextSeq = 3 * 11 * narrowestBarLenght;

    while(!stopReached)
    {
        unsigned int sequence = readSequence(addrAfterQuiet, narrowestBarLenght);
        unsigned int convertedSequence = convertSequence(sequence);

        if(sequence != START_CODE && sequence != STOP_CODE)
        {  
            if(convertedSequence == -1)
                return 0;

            unsigned int nextSequence = readSequence(addrAfterQuiet + distToNextSeq, narrowestBarLenght);

            if(nextSequence != STOP_CODE)
            {
                if(convertedSequence < 10) printf("0");
                printf("%i", convertedSequence);
            }
        }
        else if(sequence == STOP_CODE)
            stopReached = 1;

        addrAfterQuiet += distToNextSeq;
    }

    return 1;
}

void printHelp()
{
    printf("The following program reads Code128C barcodes saved in 24-bit bitmap images. Maximum image size: 768x64 pixels.\n\n");
    printf("USAGE:\ncode128reader.exe [path to the image]\n\n");
    printf("EXIT CODES:\n0 - success, 1 - invalid arguments amount, 2 - invalid file path, 3 - invalid image.");
}

int validateArgs(int argc)
{
    if(argc < 2)
    {
        printf("Insufficient amount of arguments.\n");
        printHelp();
        return 0;
    }
    else if(argc > 3)
    {
        printf("Too many arguments.\n");
        printHelp();
        return 0;
    }
    else return 1;
}

int main(int argc, char *argv[])
{
    if(!validateArgs(argc))
        return 1;

    int returnCode = 0;
    ImageInfo* imgInfo = readBmp(argv[1]);

    if(imgInfo == NULL)
    {
        printf("Invalid image file.");
        returnCode = 2;
    }
    else
    {
        unsigned char *beginAddress = imgInfo->pImg + (imgInfo->height / 2) * imgInfo->line_bytes;
        unsigned char *endAddress = beginAddress + imgInfo->width * 3;

        if(!printSequences(beginAddress, endAddress))
        {
            printf("\nGiven image contains invalid bars sequence. Make sure to load Code128C barcode.");
            returnCode = 3;
        }
    }

    freeImage(imgInfo);
    return returnCode;
}