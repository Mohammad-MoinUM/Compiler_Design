#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <stdbool.h>

int main() {
    int x = 6;
    int y = 2;
    printf("%s\n", "Testing + remap:");
    int mult = (x*y);
    printf("%d\n", (int)mult);
    printf("%s\n", "Testing - remap:");
    int divv = (x/y);
    printf("%d\n", (int)divv);
    int angle = 0;
    printf("%s\n", "Testing sin:");
    printf("%d\n", (int)sin(angle));
    printf("%s\n", "Testing cos:");
    printf("%d\n", (int)cos(angle));
    return 0;
}
