#Commands
CC=gcc
MPICC=mpicc
## this is for MPCFramework compilation
#MPICC=mpc_cc
#MPICC=vtcc -vtcc mpicc


SRC=src
TARGET_DIR=target
INCLUDE=include


## This is for scalasca instrumentation... you need to load SCALASCA
## like spack load scalasca
SCALASCA=
#SCALASCA="scalasca -instrument"


RM=rm -f
MAKEDEPEND=makedepend



### there are compilation flag. You can disable or enable optimisations with these flags.
## for example : make CCSPLIT="-DVERTICAL" CCORDER="-DOPTIMIZEDLOOP".
##
TUSELESSPART=USELESS
TUSELESSPART=NOUSELESS
CCUSELESSPART=-D$(TUSELESSPART)

TSPLIT=VERTICAL
#TSPLIT=HORIZONTAL
CCSPLIT=-D$(TSPLIT)

TVERBOSE=VERBOSE
TVERBOSE=NOVERBOSE
CCVERBOSE=-D$(TVERBOSE)

TSAVEFILE=SAVEFILE
#TSAVEFILE=NOSAVEFILE
CCSAVEFILE=-D$(TSAVEFILE)


TASSERT=ASSERT
TASSERT=NOASSERT
CCASSERT=-D$(TASSERT)

TBARRIER=NOBARRIER
#TBARRIER=BARRIER
CCBARRIER=-D$(TBARRIER)

TMPI=NOMPI
TMPI=NAIVEMPI
TMPI=FACTORIZEDMPI
CCMPI = -D$(TMPI)

TORDER=STANDARDLOOP
TORDER=OPTIMIZEDLOOP
CCORDER=-D$(TORDER)

CCALL = $(CCUSELESSPART) $(CCSPLIT) $(CCVERBOSE) $(CCASSERT) $(CCBARRIER) $(CCMPI) $(CCORDER) $(CCSAVEFILE)

GENERAL_OPTI=-O3
GENERAL_OPTI=-Ofast

#AVX=-mavx512
AVX=-mavx2
#AVX=-mno-avx
OPTI=
OPTI=-funroll-loops -mtune=native -march=native -finline-functions -ftree-vectorize -ftree-loop-vectorize 


#-fsanitize=address

CFLAGS=-Wall -g $(GENERAL_OPTI) $(OPTI) $(AVX)
LDFLAGS=-lm -fopenmp 


#Files
LBM_SOURCES = $(SRC)/main.c $(SRC)/lbm_phys.c $(SRC)/lbm_init.c $(SRC)/lbm_struct.c $(SRC)/lbm_comm.c $(SRC)/lbm_config.c
LBM_HEADERS=$(INCLUDE)/lbm_init.h $(INCLUDE)/lbm_phys.h $(INCLUDE)/lbm_config.h $(INCLUDE)/lbm_comm.h $(INCLUDE)/lbm_struct.h
LBM_OBJECTS=$(LBM_SOURCES:.c=.o)

TARGET=lbm display

all: $(TARGET)

%.o: %.c
	$(SCALASCA) $(MPICC) $(CCALL) $(CFLAGS) -c -o $@ $< $(LDFLAGS)

lbm: $(LBM_OBJECTS)
	$(SCALASCA) $(MPICC) $(CCALL) $(CFLAGS) -o $@ $^ $(LDFLAGS)

display: $(SRC)/display.c
	$(CC) $(CFLAGS) -o $@ $(SRC)/display.c

clean:
	$(RM) $(LBM_OBJECTS)
	$(RM) $(TARGET)

depend:
	$(MAKEDEPEND) -Y. $(LBM_SOURCES) $(SRC)/display.c

.PHONY: clean all depend

# DO NOT DELETE

main.o: lbm_config.h lbm_struct.h lbm_phys.h lbm_comm.h lbm_init.h
lbm_phys.o: lbm_config.h lbm_struct.h lbm_phys.h lbm_comm.h
lbm_init.o: lbm_phys.h lbm_struct.h lbm_config.h lbm_comm.h lbm_init.h
lbm_struct.o: lbm_struct.h lbm_config.h
lbm_comm.o: lbm_comm.h lbm_struct.h lbm_config.h
lbm_config.o: lbm_config.h
display.o: lbm_struct.h lbm_config.h
