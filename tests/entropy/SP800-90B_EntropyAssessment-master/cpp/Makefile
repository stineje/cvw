ARCH ?= x86

CXX ?= $(CROSS_COMPILE) g++

CXXFLAGS = -std=c++11 -fopenmp -O2 -ffloat-store -I/usr/include/jsoncpp
ifeq ($(ARCH),x86)
CXXFLAGS += -msse2 -march=native
endif

LIB = -lbz2 -lpthread -ldivsufsort -ldivsufsort64
COND_LIB = -lmpfr -lgmp
SHARED_LIB = -ljsoncpp -lcrypto
INC =
BIN_DIR = ../bin


######
# Main operations
######

all:    iid non_iid restart conditioning transpose

clean:
	rm -f ea_iid ea_non_iid ea_restart ea_conditioning ea_transpose selftest/*.res
	rm -f ${BIN_DIR}/*

install:
	@if [ ! -f ea_iid ] || [ ! -f ea_non_iid ] || [ ! -f ea_restart ] || [ ! -f ea_conditioning ] || [ ! -f ea_transpose ]; then \
		echo "Error: Some executables are missing. Please run 'make' first."; \
		exit 1; \
	fi
	mkdir -p $(BIN_DIR)
	mv ea_iid ea_non_iid ea_restart ea_conditioning ea_transpose $(BIN_DIR)

iid: iid_main.o
iid_main.o: iid_main.cpp
	$(CXX) $(CXXFLAGS) $(INC) iid_main.cpp -o ea_iid $(LIB) $(SHARED_LIB)

non_iid: non_iid_main.o	
non_iid_main.o: non_iid_main.cpp
	$(CXX) $(CXXFLAGS) $(INC) non_iid_main.cpp -o ea_non_iid $(LIB) $(SHARED_LIB)

restart: restart_main.o
restart_main.o: restart_main.cpp
	$(CXX) $(CXXFLAGS) $(INC) restart_main.cpp -o ea_restart $(LIB) $(SHARED_LIB)

conditioning: conditioning_main.o
conditioning_main.o: conditioning_main.cpp
	$(CXX) $(CXXFLAGS) $(INC) conditioning_main.cpp -o ea_conditioning $(LIB) $(COND_LIB) $(SHARED_LIB)

transpose: transpose_main.o
transpose_main.o: transpose_main.cpp
	$(CXX) $(CXXFLAGS) $(INC) transpose_main.cpp -o ea_transpose $(LIB) $(SHARED_LIB)
