#include <stdio.h>
#include "image.h"

extern int readColors(char* pImg);

int main()
{
    ImageInfo* imgInfo = readBmp("test.bmp");

    printf("Bottom left pixel: %i\n", readColors(imgInfo->pImg));
    
    uint8_t g = *(imgInfo->pImg + 1);
    printf("G: %i", g);

    freeImage(imgInfo);
    return 0;
}