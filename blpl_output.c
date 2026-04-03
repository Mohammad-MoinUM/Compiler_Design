#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <stdbool.h>

int main() {
    const int pi = 3;
    int radius = 5;
    int area = 0;
    printf("%s\n", "Radius:");
    printf("%d\n", (int)radius);
    area = ((pi+radius)+radius);
    printf("%s\n", "Area:");
    printf("%d\n", (int)area);
        if ((area>50)) {
        printf("%s\n", "Area is large");
    } else {
        printf("%s\n", "Area is small");
    }
        while ((radius>0)) {
        printf("%s\n", "Radius loop:");
        printf("%d\n", (int)radius);
        radius = (radius-1);
    }
