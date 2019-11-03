CFLAGS=-std=c11 -g -static

hkcc: hkcc.c

test: hkcc
	./test.sh

clean:
	rm -f hkcc *.o *~ tmp*

.PHONY: test clean
