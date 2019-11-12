.intel_syntax noprefix
.global main
main:
  push rbp
  mov rbp, rsp
  sub rsp, 0
  push 5
  pop rax
  ret
  pop rax
.Lreturn:
  mov rsp, rbp
  pop rbp
  ret
