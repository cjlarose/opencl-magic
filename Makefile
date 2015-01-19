OPENCLC=/System/Library/Frameworks/OpenCL.framework/Libraries/openclc
BUILD_DIR=./build
EXECUTABLE=magic
.SUFFIXES:
KERNEL_ARCH=i386 x86_64 gpu_32 gpu_64
BITCODES=$(patsubst %, square.cl.%.bc, $(KERNEL_ARCH))

$(EXECUTABLE): $(BUILD_DIR)/square.cl.o $(BUILD_DIR)/main.o $(BITCODES)
	clang -framework OpenCL -o $@ $(BUILD_DIR)/square.cl.o $(BUILD_DIR)/main.o

$(BUILD_DIR)/square.cl.o: square.cl.c
	mkdir -p $(BUILD_DIR)
	clang -c -Os -Wall -arch x86_64 -o $@ -c square.cl.c

$(BUILD_DIR)/main.o: main.c square.cl.h
	mkdir -p $(BUILD_DIR)
	clang -c -Os -Wall -arch x86_64 -o $@ -c $<

square.cl.c square.cl.h: square.cl
	$(OPENCLC) -x cl -cl-std=CL1.1 -cl-auto-vectorize-enable -emit-gcl $<

square.cl.%.bc: square.cl
	$(OPENCLC) -x cl -cl-std=CL1.1 -Os -arch $* -emit-llvm -o $@ -c $<

.PHONY: clean
clean:
	rm -rf $(BUILD_DIR) square.cl.h square.cl.c $(EXECUTABLE) *.bc
