OPENCLC=/System/Library/Frameworks/OpenCL.framework/Libraries/openclc
BUILD_DIR=./build
KERNEL_SRC=square.cl
EXECUTABLE=magic
.SUFFIXES:

$(EXECUTABLE): $(BUILD_DIR)/square.cl.o $(BUILD_DIR)/main.o square.cl.i386.bc square.cl.x86_64.bc square.cl.gpu_32.bc square.cl.gpu_64.bc
	clang -framework OpenCL -o $@ $(BUILD_DIR)/square.cl.o $(BUILD_DIR)/main.o

$(BUILD_DIR)/square.cl.o: square.cl.c
	mkdir -p $(BUILD_DIR)
	clang -c -Os -Wall -arch x86_64 -o $@ -c square.cl.c

$(BUILD_DIR)/main.o: main.c square.cl.h
	mkdir -p $(BUILD_DIR)
	clang -c -Os -Wall -arch x86_64 -o $@ -c $<

square.cl.c square.cl.h: $(KERNEL_SRC)
	$(OPENCLC) -x cl -cl-std=CL1.1 -cl-auto-vectorize-enable -emit-gcl $(KERNEL_SRC)

square.cl.i386.bc: $(KERNEL_SRC)
	$(OPENCLC) -x cl -cl-std=CL1.1 -Os -arch i386 -emit-llvm -o $@ -c $<

square.cl.x86_64.bc: $(KERNEL_SRC)
	$(OPENCLC) -x cl -cl-std=CL1.1 -Os -arch x86_64 -emit-llvm -o $@ -c $<

square.cl.gpu_32.bc: $(KERNEL_SRC)
	$(OPENCLC) -x cl -cl-std=CL1.1 -Os -arch gpu_32 -emit-llvm -o $@ -c $<

square.cl.gpu_64.bc: $(KERNEL_SRC)
	$(OPENCLC) -x cl -cl-std=CL1.1 -Os -arch gpu_64 -emit-llvm -o $@ -c $<

.PHONY: clean
clean:
	rm -rf $(BUILD_DIR) square.cl.h square.cl.c $(EXECUTABLE) *.bc
