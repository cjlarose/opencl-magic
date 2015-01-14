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