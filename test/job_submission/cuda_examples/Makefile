NODE=$(shell uname -a |  cut -f2 -d" ")

ifneq (,$(filter $(NODE),gh1 gh2 gh3 gh4)) # grace-hopper system
		CC=nvcc
		CCFLAGS= -O3 -g -Wno-deprecated-gpu-targets
        CXX=nvc++
        CXXFLAGS=-std=c++17 -O3 -g
        BINARY_POSTFIX=gh
else ifneq (,$(filter $(NODE),ice1 ice2)) # intel ice
		CC=nvcc
		CCFLAGS= -O3 -g -Wno-deprecated-gpu-targets
        CXX=nvc++
        CXXFLAGS=-std=c++17 -O3 -g
        BINARY_POSTFIX=ice
else # wolpy nodes
		CC=nvcc
		CCFLAGS= -O3 -g -Wno-deprecated-gpu-targets
        CXX=nvc++
        CXXFLAGS=-std=c++17 -O3 -g
        BINARY_POSTFIX=
endif

all: triad_cuda

triad_cuda: vector_triad.cu
	${CC} ${CCFLAGS} vector_triad.cu -o triad_cuda-${BINARY_POSTFIX}
	
clean:
	rm -f triad_cuda-${BINARY_POSTFIX} *.nsys-rep *.sqlite
