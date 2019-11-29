# C Compiler

This is a copy of [rui314/chibicc reference branch](https://github.com/rui314/chibicc/tree/reference).

"低レイヤを知りたい人のための C コンパイラ作成入門"
https://www.sigbus.info/compilerbook

# Run on Docker

```
$ docker build -t compilerbook .

$ docker run --rm -it -v /path/to/c-compiler:/home/user compilerbook
```
