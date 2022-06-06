#include <stdio.h>
#include "image.h"

extern unsigned int getNarrowestBar(unsigned char *beginAddress, unsigned char *endAddress);

int main()
{
    ImageInfo* imgInfo = readBmp("test.bmp");

    printf("Begin: %i, end: %i\n", imgInfo->pImg, imgInfo->pImg + imgInfo->width * 3);
    printf("Length of the narrowest bar = %i", getNarrowestBar(
        imgInfo->pImg, imgInfo->pImg + imgInfo->width * 3));

    freeImage(imgInfo);
    return 0;
}