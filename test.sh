#!/bin/bash
try() {
  expected="$1"
  input="$2"

  ./hkcc "$input" > tmp.s
  gcc -o tmp tmp.s
  ./tmp
  actual="$?"

  if [ "$actual" = "$expected" ]; then
    echo "$input => $actual"
  else
    echo "$input => $expected expected, but got $actual"
    exit 1
  fi
}

try 0 'return 0;'
try 42 'return 42;'
try 21 'return 5+20-4;'
try 41 'return  12 + 34 - 5 ;'
try 47 'return 5+6*7;'
try 15 'return 5*(9-6);'
try 4 'return (3+5)/2;'
try 6 'return -3 * (10 / (-5));'

try 10 'return -10+20;'
try 10 'return - -10;'
try 10 'return - - +10;'

try 0 'return 0==1;'
try 1 'return 42==42;'
try 1 'return 0!=1;'
try 0 'return 42!=42;'

try 1 'return 0<1;'
try 0 'return 1<1;'
try 0 'return 2<1;'
try 1 'return 0<=1;'
try 1 'return 1<=1;'
try 0 'return 2<=1;'

try 1 'return 1>0;'
try 0 'return 1>1;'
try 0 'return 1>2;'
try 1 'return 1>=0;'
try 1 'return 1>=1;'
try 0 'return 1>=2;'

try 3 'a=3; return a;'
try 8 'a=3; z=5; return a+z;'
try 13 'a=5; b=a+3; c=b+a; a=1; return c;'

try 3 'abc=3; return abc;'
try 8 'a1z=3; b2y=5; return a1z+b2y;'
try 13 'foo=5; bar=foo+3; baz=bar+foo; foo=1; return baz;'

try 1 'return 1; 2; 3;'
try 2 '1; return 2; 3;'
try 3 '1; 2; return 3;'

echo OK
