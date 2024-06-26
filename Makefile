ifndef PREFIX
	PREFIX := /usr/local
endif

SOFTNAME := sp
OBJLIB := lib$(SOFTNAME).a
TESTS := sp_cs sp_gtk

ifdef DEBUG
OPTOPT := -O0 -g
endif

all : $(OBJLIB) $(TESTS)

CC := gcc
LINKER := gcc

CFLAGS := $(OPTOPT) -I. 
LFLAGS := $(OPTOPT) 

MAKE_DEP := gcc -MM

SRCS := $(filter-out $(addsuffix .c, $(TESTS)), $(wildcard *.c))
DEPS := $(patsubst %.c, %.d, $(wildcard *.c))
OBJS := $(patsubst %.c, %.o, $(SRCS))

$(OBJLIB) : $(OBJLIB)($(OBJS))

sinclude $(DEPS)

%.d : %.c
	@$(MAKE_DEP) $^ 2>/dev/null | sed 's/\($*\)\.o[ :]*/\1.o $@ :/g' > $@

sp_gtk.o : sp_gtk.c
	$(CC) -c $(CFLAGS) `pkg-config --cflags gtk+-3.0` $< -o $@

sp_gtk : sp_gtk.o
	$(LINKER) $(LFLAGS) $< -o $@ -L. -l$(SOFTNAME) `pkg-config --libs gtk+-3.0` -lm

sp_cs.o : sp_cs.c
	$(CC) -c $(CFLAGS) $< `pkg-config --cflags ncursesw` -o $@

sp_cs : sp_cs.o
	$(LINKER) $(LFLAGS) $< -o $@ -L. -l$(SOFTNAME) `pkg-config --libs ncursesw` -lm

$(TESTS) : $(OBJLIB)

$(SRCS) *.h : Makefile
	@touch $@

clean:  
	rm -rf *.o $(OBJLIB) *.d $(TESTS) 

install:
	install -Dm644 $(OBJLIB) -t $(PREFIX)/lib/
	install -Dm644 $(SOFTNAME).h -t $(PREFIX)/include/

install_test: 
	install -Dm755 $(TESTS) -t $(PREFIX)/bin/

.PHONY: all clean install install_test

