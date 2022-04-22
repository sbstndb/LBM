#Commands
CC=gcc
MPICC=mpicc
#MPICC=vtcc -vtcc mpicc
RM=rm -f
MAKEDEPEND=makedepend

TUSELESSPART=USELESS
TUSELESSPART=NOUSELESS
CCUSELESSPART=-D$(TUSELESSPART)

TSPLIT=VERTICAL
#TSPLIT=HORIZONTAL
CCSPLIT=-D$(TSPLIT)

TVERBOSE=VERBOSE
TVERBOSE=NOVERBOSE
CCVERBOSE=-D$(TVERBOSE)

TASSERT=ASSERT
TASSERT=NOASSERT
CCASSERT=-D$(TASSERT)

TBARRIER=NOBARRIER
#TBARRIER=BARRIER
CCBARRIER=-D$(TBARRIER)

TMPI=NAIVEMPI
#TMPI=FACTORIZEDMPI
CCMPI = -D$(TMPI)

CCALL = $(CCUSELESSPART) $(CCSPLIT) $(CCVERBOSE) $(CCASSERT) $(CCBARRIER) $(CCMPI)


AVX=-mavx512
AVX=-mavx2
#AVX=-mno-avx
OPTI=
OPTI=-funroll-loops -mtune=native -march=native -finline-functions -ftree-vectorize -ftree-loop-vectorize 


#flags
CFLAGS=-Wall -g -O3 $(OPTI) $(AVX)
LDFLAGS=-lm

#Files
LBM_SOURCES=main.c lbm_phys.c lbm_init.c lbm_struct.c lbm_comm.c lbm_config.c
LBM_HEADERS=$(wildcards:*.h)
LBM_OBJECTS=$(LBM_SOURCES:.c=.o)

TARGET=lbm display

all: $(TARGET)

%.o: %.c
	$(MPICC) $(CCALL) $(CFLAGS) -c -o $@ $<

lbm: $(LBM_OBJECTS)
	$(MPICC) $(CCALL) $(CFLAGS) -o $@ $^ $(LDFLAGS)

display: display.c
	$(CC) $(CFLAGS) -o $@ display.c

clean:
	$(RM) $(LBM_OBJECTS)
	$(RM) $(TARGET)

depend:
	$(MAKEDEPEND) -Y. $(LBM_SOURCES) display.c

.PHONY: clean all depend

# DO NOT DELETE

main.o: lbm_config.h lbm_struct.h lbm_phys.h lbm_comm.h lbm_init.h
lbm_phys.o: lbm_config.h lbm_struct.h lbm_phys.h lbm_comm.h
lbm_init.o: lbm_phys.h lbm_struct.h lbm_config.h lbm_comm.h lbm_init.h
lbm_struct.o: lbm_struct.h lbm_config.h
lbm_comm.o: lbm_comm.h lbm_struct.h lbm_config.h
lbm_config.o: lbm_config.h
display.o: lbm_struct.h lbm_config.h
