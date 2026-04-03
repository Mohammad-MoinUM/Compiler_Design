#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <stdbool.h>

int main() {
    int counter = 1;
    const int max_count = 5;
    printf("%s\n", "Counting from 1 to 5:");
        while ((counter<=max_count)) {
        printf("%d\n", (int)counter);
        counter = (counter+1);
    }
    printf("%s\n", "Loop complete");
    int angle = 0;
    printf("%s\n", "sin(0) = ");
    printf("%d\n", (int)sin(angle));
    printf("%s\n", "cos(0) = ");
    printf("%d\n", (int)cos(angle));
    return 0;
}
