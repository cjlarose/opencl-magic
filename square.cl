// Simple OpenCL kernel that squares an input array.
// This code is stored in a file called mykernel.cl.
// You can name your kernel file as you would name any other
// file.  Use .cl as the file extension for all kernel
// source files.

// Kernel block.                                      //   1
kernel void square(int max, global float* output)
{
    size_t i = get_global_id(0);
    if (i > max)
        return;

    size_t x = i / 9 + 1;
    size_t y = i % 9 + 1;
    int magic = 1;

    //printf("i = %d, x = %d, y = %d\n", i, x, y);

    int taken[10] = {0};
    int a1, a2, a3, b1, b2, b3, c1, c2, c3;
    b2 = 5;
    taken[5] = 1;

    a1 = x;
    c3 = 10 - x;
    if (taken[x] || taken[c3])
        return;
    taken[x] = taken[c3] = 1;

    a2 = y; c2 = 10 - y; a3 = 15 - x - y; c1 = 10 - a3; b1 = 15 - x - c1; b3 = 10 - b1;
    if (a3 < 1 || a3 > 9 || b1 < 1 || b1 > 9)
        magic = 0;
    else if (taken[y] || taken[c2] || taken[a3] || taken[c1] || taken[b1] || taken[b3])
        magic = 0;
    else if (y == a3 || y == c1 || y == b1 || y == b3 || a3 == b1 || a3 == b3)
        magic = 0;

    output[i] = magic ? 1.0 : 0.0;
}