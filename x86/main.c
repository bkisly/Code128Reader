#include <stdio.h>
#include "image.h"

extern int add(int a, int b);

int main()
{
    int a = 3;
    int b = 4;
    printf("%i + %i = %i", a, b, add(a, b));
    return 0;
}