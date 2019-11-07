CFLAGS=-std=c11 -g -static -fno-common
SRCS=$(wildcard *.c)
OBJS=$(SRCS:.c=.o)

hkcc: $(OBJS)
	$(CC) -o $@ $(OBJS) $(LDFLAGS)

$(OBJS): hkcc.h

test: hkcc
	./test.sh

clean:
	rm -f hkcc *.o *~ tmp*

.PHONY: test clean
