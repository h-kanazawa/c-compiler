#include "hkcc.h"


int main(int argc, char **argv) {
  if (argc != 2) {
    error("invalid number of arguments");
    return 1;
  }

  user_input = argv[1];
  token = tokenize();
  Node *node = program();

  codegen(node);

  return 0;
}
