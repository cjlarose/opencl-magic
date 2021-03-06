#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <string.h>

// This include pulls in everything you need to develop with OpenCL in OS X.
#include <OpenCL/opencl.h>

// Include the header file generated by Xcode.  This header file contains the
//  kernel block declaration.                                             // 1
#include "square.cl.h"

// Hard-coded number of values to test, for convenience.
#define NUM_VALUES (16 * 16 * 16 * 16 * 16 * 16 * 16)
#define GLOBAL_WORK_SIZE (16 * 16 * 16 * 16 * 16 * 16)

int verify(uint8_t* test_out, int offset, size_t n) {
    int i, num_magic = 0;
    for (i = 0; i < n; i++) {
        if (test_out[i]) {
            num_magic++;
            
            int k = i + offset;
            int divisor = 16 * 16 * 16 * 16 * 16 * 16;
            
            int a = k / divisor + 1;
            k %= divisor;
            divisor /= 16;
            
            int b = k / divisor + 1;
            k %= divisor;
            divisor /= 16;
            
            int c = k / divisor + 1;
            k %= divisor;
            divisor /= 16;
            
            int d = k / divisor + 1;
            k %= divisor;
            divisor /= 16;
            
            int e = k / divisor + 1;
            k %= divisor;
            divisor /= 16;
            
            int f = k / divisor + 1;
            k %= divisor;
            divisor /= 16; // divisor == 1;
            
            int g = k / divisor + 1;
            
            int a1, a2, a3, a4, b1, b2, b3, b4, c1, c2, c3, c4, d1, d2, d3, d4;
            a1 = a; a2 = f; a3 = 34 - a - c - f; a4 = c;
            b1 = g; b2 = d; b3 = e; b4 = 34 - d - e - g;
            c1 = b + c - g; c2 = a + b - e; c3 = 34 - a - b - d; c4 = d + e + g - b - c;
            d1 = 34 - a - b - c; d2 = 34 - a - b - d + e - f; d3 = 2 * a + b + c + d - e + f - 34; d4 = b;
            
            assert(a1 + a2 + a3 + a4 == 34);
            assert(b1 + b2 + b3 + b4 == 34);
            assert(c1 + c2 + c3 + c4 == 34);
            assert(d1 + d2 + d3 + d4 == 34);
            
            assert(a1 + b1 + c1 + d1 == 34);
            assert(a2 + b2 + c2 + d2 == 34);
            assert(a3 + b3 + c3 + d3 == 34);
            assert(a4 + b4 + c4 + d4 == 34);
            
            assert(a1 + b2 + c3 + d4 == 34);
            assert(a4 + b3 + c2 + d1 == 34);

            printf("a = %2d, b = %2d, c = %2d, d = %2d, e = %2d, f = %2d, g = %2d\n", a, b, c, d, e, f, g);
        }
    }
    printf("Squares this round: %d\n", num_magic);
    return num_magic;
}

int main (int argc, const char * argv[]) {
    char name[128];
    
    // First, try to obtain a dispatch queue that can send work to the
    // GPU in our system.                                             // 2
    dispatch_queue_t queue =
    gcl_create_dispatch_queue(CL_DEVICE_TYPE_GPU, NULL);
    
    // In the event that our system does NOT have an OpenCL-compatible GPU,
    // we can use the OpenCL CPU compute device instead.
    if (queue == NULL) {
        queue = gcl_create_dispatch_queue(CL_DEVICE_TYPE_CPU, NULL);
    }
    
    // This is not required, but let's print out the name of the device
    // we are using to do work.  We could use the same function,
    // clGetDeviceInfo, to obtain all manner of information about the device.
    cl_device_id gpu = gcl_get_device_id_with_dispatch_queue(queue);
    clGetDeviceInfo(gpu, CL_DEVICE_NAME, 128, name, NULL);
    fprintf(stdout, "Created a dispatch queue using the %s\n", name);

    // Once the computation using CL is done, will have to read the results
    // back into our application's memory space.  Allocate some space for that.
    uint8_t* test_out = malloc(sizeof(cl_uchar) * GLOBAL_WORK_SIZE);
    
    if (test_out == NULL) {
        fprintf(stderr, "Unable to allocate memory for output vector");
        exit(1);
    }
    
    // The output array is not initalized; we're going to fill it up when
    // we execute our kernel.                                             // 4
    void* mem_out = gcl_malloc(sizeof(cl_uchar) * GLOBAL_WORK_SIZE,
                               NULL, CL_MEM_WRITE_ONLY);
    
    if (mem_out == NULL) {
        fprintf(stderr, "Unable to allocate memory for cl output vector");
        exit(1);
    }
    
    int i;
    int num_magic = 0;

    for (i = 0; i < NUM_VALUES / GLOBAL_WORK_SIZE; i++) {
      //printf("Round %d of %d\n", i, NUM_VALUES / GLOBAL_WORK_SIZE);
      //printf("Processing values %d through %d\n", i * GLOBAL_WORK_SIZE, (i + 1) * GLOBAL_WORK_SIZE - 1);
      memset(test_out, 0, sizeof(cl_uchar) * GLOBAL_WORK_SIZE);
      // Dispatch the kernel block using one of the dispatch_ commands and the
      // queue created earlier.                                            // 5
      
      dispatch_sync(queue, ^{
          // Although we could pass NULL as the workgroup size, which would tell
          // OpenCL to pick the one it thinks is best, we can also ask
          // OpenCL for the suggested size, and pass it ourselves.
          size_t wgs;
          gcl_get_kernel_block_workgroup_info(square_order_4_kernel,
                                              CL_KERNEL_WORK_GROUP_SIZE,
                                              sizeof(wgs), &wgs, NULL);
          
          // The N-Dimensional Range over which we'd like to execute our
          // kernel.  In this case, we're operating on a 1D buffer, so
          // it makes sense that the range is 1D.
          cl_ndrange range = {                                              // 6
              1,                     // The number of dimensions to use.
              
              {0, 0, 0},             // The offset in each dimension.  To specify
              // that all the data is processed, this is 0
              // in the test case.                   // 7
              
              {GLOBAL_WORK_SIZE, 0, 0},    // The global range—this is how many items
              // IN TOTAL in each dimension you want to
              // process.
              
              {wgs, 0, 0}            // The local size of each workgroup.  This
              // determines the number of work items per
              // workgroup.  It indirectly affects the
              // number of workgroups, since the global
              // size / local size yields the number of
              // workgroups.  In this test case, there are
              // NUM_VALUE / wgs workgroups.
          };
          // Calling the kernel is easy; simply call it like a function,
          // passing the ndrange as the first parameter, followed by the expected
          // kernel parameters.  Note that we case the 'void*' here to the
          // expected OpenCL types.  Remember, a 'float' in the
          // kernel, is a 'cl_float' from the application's perspective.   // 8
          
          square_order_4_kernel(&range, NUM_VALUES - 1, (cl_ulong) i * GLOBAL_WORK_SIZE, (cl_uchar*) mem_out);
          
          // Getting data out of the device's memory space is also easy;
          // use gcl_memcpy.  In this case, gcl_memcpy takes the output
          // computed by the kernel and copies it over to the
          // application's memory space.                                   // 9
          
          gcl_memcpy(test_out, mem_out, sizeof(cl_uchar) * GLOBAL_WORK_SIZE);
      });

      // Print results
      num_magic += verify(test_out, i * GLOBAL_WORK_SIZE, GLOBAL_WORK_SIZE);
      
    }
    printf("Total Magic Squares: %d\n", num_magic);
    
    // Don't forget to free up the CL device's memory when you're done. // 10
    gcl_free(mem_out);
    
    // And the same goes for system memory, as usual.
    free(test_out);
    
    // Finally, release your queue just as you would any GCD queue.    // 11
    dispatch_release(queue);
}
