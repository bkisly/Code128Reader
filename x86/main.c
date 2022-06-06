#include <stdio.h>
#include "image.h"

extern unsigned int getNarrowestBar(char *beginAddress, char *endAddress);

int main()
{
    ImageInfo* imgInfo = readBmp("test.bmp");

    printf("Begin: %i, end: %i\n", imgInfo->pImg, imgInfo->pImg + imgInfo->width * 3);
    printf("Distance to first black pixel = %i", getNarrowestBar(
        imgInfo->pImg, imgInfo->pImg + imgInfo->width * 3));

    freeImage(imgInfo);
    return 0;
}