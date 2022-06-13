#define START_CODE 1692
#define STOP_CODE 1594
#define INVALID_SEQ_MSG "Given image contains invalid bars sequence. Make sure to load Code128C barcode."
#define MAX_BUF_SIZE 128

#include <stdio.h>
#include <string.h>
#include "image.h"

extern unsigned char *addressAfterQuiet(unsigned char *beginAddress, unsigned char *endAddress);
extern uint8_t getNarrowestBar(unsigned char *beginAddress, unsigned char *endAddress);
extern unsigned int readSequence(unsigned char *beginAddres, uint8_t barLength);
extern int8_t convertSequence(unsigned int sequence);

void writeSequences(ImageInfo *imgInfo, char *buffer)
{
    unsigned char *beginAddress = imgInfo->pImg + (imgInfo->height / 2) * imgInfo->line_bytes;
    unsigned char *endAddress = beginAddress + imgInfo->width * 3;

    int stopReached = 0;
    unsigned char *addrAfterQuiet = addressAfterQuiet(beginAddress, endAddress);
    uint8_t narrowestBarLenght = getNarrowestBar(addrAfterQuiet, endAddress);
    int distToNextSeq = 3 * 11 * narrowestBarLenght;

    while(!stopReached)
    {
        unsigned int sequence = readSequence(addrAfterQuiet, narrowestBarLenght);
        unsigned int convertedSequence = convertSequence(sequence);

        if(sequence != START_CODE && sequence != STOP_CODE)
        {  
            if(convertedSequence == -1)
            {
                strcpy(buffer, INVALID_SEQ_MSG);
                return;
            }

            unsigned int nextSequence = readSequence(addrAfterQuiet + distToNextSeq, narrowestBarLenght);

            if(nextSequence != STOP_CODE)
            {
                char newSeq[2];
                newSeq[0] = (convertedSequence / 10) + '0';
                newSeq[1] = (convertedSequence % 10) + '0';
                strncat(buffer, newSeq, 2);
            }
        }
        else if(sequence == STOP_CODE)
            stopReached = 1;

        addrAfterQuiet += distToNextSeq;
    }
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
    ImageInfo *imgInfo = readBmp(argv[1]);

    if(imgInfo == NULL)
    {
        printf("Invalid image file.");
        returnCode = 2;
    }
    else
    {
        
        char buffer[MAX_BUF_SIZE] = "";
        writeSequences(imgInfo, buffer);

        if(strcmp(buffer, INVALID_SEQ_MSG) == 0)
            returnCode = 3;

        printf("%s\n", buffer);
    }

    freeImage(imgInfo);
    return returnCode;
}