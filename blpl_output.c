#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <stdbool.h>

int main() {
    int x = 10;
    int y = 3;
    int z = 0;
    int a = (12*2);
    int b = (7+5);
    int c = (20-4);
    int d = (100/5);
    const int pi = 3;
    const int fixed = 42;
    printf("%s\n", "=== Start BLPL Large Test ===");
    printf("%s\n", "x =");
    printf("%d\n", (int)x);
    printf("%s\n", "y =");
    printf("%d\n", (int)y);
    int f1 = 12.500000;
    int f2 = 0.750000;
    printf("%s\n", "Float values:");
    printf("%d\n", (int)f1);
    printf("%d\n", (int)f2);
    printf("%s\n", "Trig tests:");
    printf("%d\n", (int)sin(x));
    printf("%d\n", (int)cos(x));
    printf("%d\n", (int)tan(y));
    printf("%d\n", (int)(1.0/cos(y)));
        if ((x>y)) {
        printf("%s\n", "x boro y theke");
    }
    return 0;
}
