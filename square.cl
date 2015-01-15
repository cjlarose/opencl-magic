// Simple OpenCL kernel that squares an input array.
// This code is stored in a file called mykernel.cl.
// You can name your kernel file as you would name any other
// file.  Use .cl as the file extension for all kernel
// source files.

// Kernel block.                                      //   1

int is_magic_order_3(int a, int b)
{
    int taken[10] = {0};
    int a1, a2, a3, b1, b2, b3, c1, c2, c3;
    b2 = 5;
    taken[5] = 1;

    a1 = a;
    c3 = 10 - a;
    if (taken[a] || taken[c3])
        return 0;
    taken[a] = taken[c3] = 1;

    a2 = b; c2 = 10 - b; a3 = 15 - a - b; c1 = 10 - a3; b1 = 15 - a - c1; b3 = 10 - b1;
    if (a3 < 1 || a3 > 9 || b1 < 1 || b1 > 9)
        return 0;
    if (taken[b] || taken[c2] || taken[a3] || taken[c1] || taken[b1] || taken[b3])
        return 0;
    if (b == a3 || b == c1 || b == b1 || b == b3 || a3 == b1 || a3 == b3)
        return 0;

    return 1;
}

int is_magic_order_4(int a, int b, int c, int d, int e, int f, int g) {
    int taken[17] = {0};
    int a1, a2, a3, a4, b1, b2, b3, b4, c1, c2, c3, c4, d1, d2, d3, d4;
    
    a1 = a;
    taken[a1] = 1;
    
    d4 = b;
    if (taken[d4])
        return 0;
    taken[d4] = 1;
    
    a4 = c;
    if (taken[a4])
        return 0;
    taken[a4] = 1;
    
    b2 = d;
    if (taken[b2])
        return 0;
    taken[b2] = 1;
    
    b3 = e;
    if (taken[b3])
        return 0;
    taken[b3] = 1;
    
    a2 = f;
    if (taken[a2])
        return 0;
    taken[a2] = 1;
    
    b1 = g;
    if (taken[b1])
        return 0;
    taken[b1] = 1;
    
    a3 = 34 - a - c - f; b4 = 34 - d - e - g;         c1 = b + c - g;
    c2 = a + b - e;      c3 = 34 - a - b - d;         c4 = d + e + g - b - c;
    d1 = 34 - a - b - c; d2 = 34 - a - b - d + e - f; d3 = 2 * a + b + c + d - e + f - 34;
    if (a3 < 1 || a3 > 16 ||
        b4 < 1 || b4 > 16 ||
        c1 < 1 || c1 > 16 ||
        c2 < 1 || c2 > 16 ||
        c3 < 1 || c3 > 16 ||
        c4 < 1 || c4 > 16 ||
        d1 < 1 || d1 > 16 ||
        d2 < 1 || d2 > 16 ||
        d3 < 1 || d3 > 16)
        return 0;
    if (taken[a3] || taken[b4] || taken[c1] || taken[c2] || taken[c3] || taken[c4] || taken[d1] || taken[d2] || taken[d3])
        return 0;
    if (a3 == b4 || a3 == c1 || a3 == c2 || a3 == c3 || a3 == c4 || a3 == d1 || a3 == d2 || a3 == d3 ||
        b4 == c1 || b4 == c2 || b4 == c3 || b4 == c4 || b4 == d1 || b4 == d2 || b4 == d3 ||
        c1 == c2 || c1 == c3 || c1 == c4 || c1 == d1 || c1 == d2 || c1 == d3 ||
        c2 == c3 || c2 == c4 || c2 == d1 || c2 == d2 || c2 == d3 ||
        c3 == c4 || c3 == d1 || c3 == d2 || c3 == d3 ||
        c4 == d1 || c4 == d2 || c4 == d3 ||
        d1 == d2 || d1 == d3 ||
        d2 == d3)
        return 0;
    
    return 1;
}

kernel void square_order_3(int max, global float* output)
{
    size_t i = get_global_id(0);
    if (i > max)
        return;

    size_t x = i / 9 + 1;
    size_t y = i % 9 + 1;

    //printf("i = %d, x = %d, y = %d\n", i, x, y);

    output[i] = is_magic_order_3(x, y) ? 1.0 : 0.0;
}

kernel void square_order_4(int max, global float* output)
{
    size_t global_id = get_global_id(0);
    if (global_id > max)
        return;
    
    size_t i = global_id;
    int divisor = 15 * 14 * 13 * 12 * 11 * 10;
    
    size_t a = i / divisor + 1;
    i %= divisor;
    divisor /= 15;
    
    size_t b = i / divisor + 1;
    i %= divisor;
    divisor /= 14;
    
    size_t c = i / divisor + 1;
    i %= divisor;
    divisor /= 13;
    
    size_t d = i / divisor + 1;
    i %= divisor;
    divisor /= 12;
    
    size_t e = i / divisor + 1;
    i %= divisor;
    divisor /= 11;
    
    size_t f = i / divisor + 1;
    i %= divisor;
    divisor /= 10; // divisor == 1;
    
    size_t g = i / divisor + 1;
    //printf("i = %d\n", i);
    //printf("a = %d, b = %d, c = %d,  = %d, e = %d, f = %d, g = %d\n", a, b, c, d, e, f, g);
    output[global_id] = is_magic_order_4(a, b, c, d, e, f, g) ? 1.0 : 0.0;
}