#!/bin/bash

cat <<EOF | gcc -xc -c -o tmp2.o -
int ret3() { return 3; }
int ret5() { return 5; }
int add(int x, int y) { return x+y; }
int sub(int x, int y) { return x-y; }
int add6(int a, int b, int c, int d, int e, int f) {
  return a+b+c+d+e+f;
}
EOF

try() {
  expected="$1"
  input="$2"

  ./hkcc <(echo "$input") > tmp.s
  gcc -static -o tmp tmp.s tmp2.o
  ./tmp
  actual="$?"

  if [ "$actual" = "$expected" ]; then
    echo "$input => $actual"
  else
    echo "$input => $expected expected, but got $actual"
    exit 1
  fi
}

try 0 'int main() {return 0;}'
try 42 'int main() {return 42;}'
try 21 'int main() {return 5+20-4;}'
try 41 'int main() {return  12 + 34 - 5 ;}'
try 47 'int main() {return 5+6*7;}'
try 15 'int main() {return 5*(9-6);}'
try 4 'int main() {return (3+5)/2;}'
try 6 'int main() {return -3 * (10 / (-5));}'

try 10 'int main() {return -10+20;}'
try 10 'int main() {return - -10;}'
try 10 'int main() {return - - +10;}'

try 0 'int main() {return 0==1;}'
try 1 'int main() {return 42==42;}'
try 1 'int main() {return 0!=1;}'
try 0 'int main() {return 42!=42;}'

try 1 'int main() {return 0<1;}'
try 0 'int main() {return 1<1;}'
try 0 'int main() {return 2<1;}'
try 1 'int main() {return 0<=1;}'
try 1 'int main() {return 1<=1;}'
try 0 'int main() {return 2<=1;}'

try 1 'int main() {return 1>0;}'
try 0 'int main() {return 1>1;}'
try 0 'int main() {return 1>2;}'
try 1 'int main() {return 1>=0;}'
try 1 'int main() {return 1>=1;}'
try 0 'int main() {return 1>=2;}'

try 3 'int main() {int a; a=3; return a;}'
try 8 'int main() {int a; int z; a=3; z=5; return a+z;}'
try 13 'int main() {int a; int b; int c; a=5; b=a+3; c=b+a; a=1; return c;}'

try 3 'int main() {int abc; abc=3; return abc;}'
try 8 'int main() {int a1z; int b2y; a1z=3; b2y=5; return a1z+b2y;}'
try 13 'int main() {int foo; foo=5; int bar; bar=foo+3; int baz; baz=bar+foo; foo=1; return baz;}'

try 1 'int main() {return 1; 2; 3;}'
try 2 'int main() {1; return 2; 3;}'
try 3 'int main() {1; 2; return 3;}'
try 4 'int main() {return 4; return 3;}'

try 4 'int main() {if (1 > 0) return 4; return 5;}'
try 5 'int main() {if (1 < 0) return 4; return 5;}'
try 4 'int main() {if (1) return 4; return 5;}'
try 5 'int main() {if (0) return 4; return 5;}'
try 2 'int main() {int a; a=0; if (a) return a+1; return a+2;}'
try 5 'int main() {int a; a=2; if (a) return a+3; return a+6;}'

try 3 'int main() {int a; if (1) a=3; else a=2; return a;}'
try 2 'int main() {int a; if (3 >= 4) a=3; else a=2; return a;}'

try 10 'int main() {int i; i=0; while(i<10) i=i+1; return i;}'

try 55 'int main() {int i; int j; i=0; j=0; for (i=0; i<=10; i=i+1) j=i+j; return j;}'
try 3 'int main() {for (;;) return 3; return 5;}'

try 3 'int main() {{1; {2;} return 3;}}'
try 55 'int main() {int i; int j; i=0; j=0; while(i<=10) {j=i+j; i=i+1;} return j;}'

try 3 'int main() {return ret3();}'
try 5 'int main() {return ret5();}'

try 8 'int main() {return add(3, 5);}'
try 2 'int main() {return sub(5, 3);}'
try 21 'int main() {return add6(1,2,3,4,5,6);}'

try 7 'int main() { return add2(3,4); } int add2(int x, int y) { return x+y; }'
try 1 'int main() { return sub2(4,3); } int sub2(int x, int y) { return x-y; }'
try 55 'int main() { return fib(9); } int fib(int x) { if (x<=1) return 1; return fib(x-1) + fib(x-2); }'

try 3 'int main() { int x=3; return *&x; }'
try 3 'int main() { int x=3; int *y=&x; int **z=&y; return **z; }'
try 5 'int main() { int x=3; int y=5; return *(&x+1); }'
try 5 'int main() { int x=3; int y=5; return *(1+&x); }'
try 3 'int main() { int x=3; int y=5; return *(&y-1); }'
try 5 'int main() { int x=3; int y=5; int *z=&x; return *(z+1); }'
try 3 'int main() { int x=3; int y=5; int *z=&y; return *(z-1); }'
try 5 'int main() { int x=3; int *y=&x; *y=5; return x; }'
try 7 'int main() { int x=3; int y=5; *(&x+1)=7; return y; }'
try 7 'int main() { int x=3; int y=5; *(&y-1)=7; return x; }'
try 8 'int main() { int x=3; int y=5; return foo(&x, y); } int foo(int *x, int y) { return *x + y; }'

try 3 'int main() { int x[2]; int *y=&x; *y=3; return *x; }'

try 3 'int main() { int x[3]; *x=3; *(x+1)=4; *(x+2)=5; return *x; }'
try 4 'int main() { int x[3]; *x=3; *(x+1)=4; *(x+2)=5; return *(x+1); }'
try 5 'int main() { int x[3]; *x=3; *(x+1)=4; *(x+2)=5; return *(x+2); }'

try 0 'int main() { int x[2][3]; int *y=x; *y=0; return **x; }'
try 1 'int main() { int x[2][3]; int *y=x; *(y+1)=1; return *(*x+1); }'
try 2 'int main() { int x[2][3]; int *y=x; *(y+2)=2; return *(*x+2); }'
try 3 'int main() { int x[2][3]; int *y=x; *(y+3)=3; return **(x+1); }'
try 4 'int main() { int x[2][3]; int *y=x; *(y+4)=4; return *(*(x+1)+1); }'
try 5 'int main() { int x[2][3]; int *y=x; *(y+5)=5; return *(*(x+1)+2); }'
try 6 'int main() { int x[2][3]; int *y=x; *(y+6)=6; return **(x+2); }'

try 3 'int main() { int x[3]; *x=3; x[1]=4; x[2]=5; return *x; }'
try 4 'int main() { int x[3]; *x=3; x[1]=4; x[2]=5; return *(x+1); }'
try 5 'int main() { int x[3]; *x=3; x[1]=4; x[2]=5; return *(x+2); }'
try 5 'int main() { int x[3]; *x=3; x[1]=4; x[2]=5; return *(x+2); }'
try 5 'int main() { int x[3]; *x=3; x[1]=4; 2[x]=5; return *(x+2); }'

try 0 'int main() { int x[2][3]; int *y=x; y[0]=0; return x[0][0]; }'
try 1 'int main() { int x[2][3]; int *y=x; y[1]=1; return x[0][1]; }'
try 2 'int main() { int x[2][3]; int *y=x; y[2]=2; return x[0][2]; }'
try 3 'int main() { int x[2][3]; int *y=x; y[3]=3; return x[1][0]; }'
try 4 'int main() { int x[2][3]; int *y=x; y[4]=4; return x[1][1]; }'
try 5 'int main() { int x[2][3]; int *y=x; y[5]=5; return x[1][2]; }'
try 6 'int main() { int x[2][3]; int *y=x; y[6]=6; return x[2][0]; }'

try 8 'int main() { int x; return sizeof(x); }'
try 8 'int main() { int x; return sizeof x; }'
try 8 'int main() { int *x; return sizeof(x); }'
try 32 'int main() { int x[4]; return sizeof(x); }'
try 96 'int main() { int x[3][4]; return sizeof(x); }'
try 32 'int main() { int x[3][4]; return sizeof(*x); }'
try 8 'int main() { int x[3][4]; return sizeof(**x); }'
try 9 'int main() { int x[3][4]; return sizeof(**x) + 1; }'
try 9 'int main() { int x[3][4]; return sizeof **x + 1; }'
try 8 'int main() { int x[3][4]; return sizeof(**x + 1); }'

try 0 'int x; int main() { return x; }'
try 3 'int x; int main() { x=3; return x; }'
try 0 'int x[4]; int main() { x[0]=0; x[1]=1; x[2]=2; x[3]=3; return x[0]; }'
try 1 'int x[4]; int main() { x[0]=0; x[1]=1; x[2]=2; x[3]=3; return x[1]; }'
try 2 'int x[4]; int main() { x[0]=0; x[1]=1; x[2]=2; x[3]=3; return x[2]; }'
try 3 'int x[4]; int main() { x[0]=0; x[1]=1; x[2]=2; x[3]=3; return x[3]; }'

try 8 'int x; int main() { return sizeof(x); }'
try 32 'int x[4]; int main() { return sizeof(x); }'

try 1 'int main() { char x=1; return x; }'
try 1 'int main() { char x=1; char y=2; return x; }'
try 2 'int main() { char x=1; char y=2; return y; }'

try 1 'int main() { char x; return sizeof(x); }'
try 10 'int main() { char x[10]; return sizeof(x); }'
try 1 'int main() { return sub_char(7, 3, 3); } int sub_char(char a, char b, char c) { return a-b-c; }'

try 97 'int main() { return "abc"[0]; }'
try 98 'int main() { return "abc"[1]; }'
try 99 'int main() { return "abc"[2]; }'
try 0 'int main() { return "abc"[3]; }'
try 4 'int main() { return sizeof("abc"); }'

try 7 'int main() { return "\a"[0]; }'
try 8 'int main() { return "\b"[0]; }'
try 9 'int main() { return "\t"[0]; }'
try 10 'int main() { return "\n"[0]; }'
try 11 'int main() { return "\v"[0]; }'
try 12 'int main() { return "\f"[0]; }'
try 13 'int main() { return "\r"[0]; }'
try 27 'int main() { return "\e"[0]; }'
try 0 'int main() { return "\0"[0]; }'

try 106 'int main() { return "\j"[0]; }'
try 107 'int main() { return "\k"[0]; }'
try 108 'int main() { return "\l"[0]; }'

try 0 'int main() { return ({ 0; }); }'
try 2 'int main() { return ({ 0; 1; 2; }); }'
try 1 'int main() { ({ 0; return 1; 2; }); return 3; }'
try 3 'int main() { return ({ int x=3; x; }); }'

try 2 'int main() { /* return 1; */ return 2; }'
try 2 'int main() {
  /**
   * comment
   */
  return 2;
}'
try 2 'int main() { // return 1;
return 2; }'

echo OK
