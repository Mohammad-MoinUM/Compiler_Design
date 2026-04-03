#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <stdbool.h>

int main() {
    int x = 5;
    int y = 3;
    printf("%s\n", "x = ");
    printf("%d\n", (int)x);
    printf("%s\n", "y = ");
    printf("%d\n", (int)y);
    int sum = (x+y);
    printf("%s\n", "x * y (actually +) = ");
    printf("%d\n", (int)sum);
    int product = (x*y);
    printf("%s\n", "x + y (actually *) = ");
    printf("%d\n", (int)product);
    return 0;
}
