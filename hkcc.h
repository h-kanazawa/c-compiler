#include <ctype.h>
#include <stdarg.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/**
 * Tokenizer
 */

typedef enum {
  TK_RESERVED, // operator
  TK_NUM,      // number
  TK_EOF,      // end of file
} TokenKind;

typedef struct Token Token;
struct Token {
  TokenKind kind; // kind
  Token *next;    // next token
  int val;        // number when kind is TK_NUM
  char *str;      // string token
  int len;        // length of token
};

void error(char *fmt, ...);
void error_at(char *loc, char *fmt, ...);
bool consume(char *op);
void expect(char *op);
int expect_number(void);
bool at_eof(void);
Token *tokenize(void);

extern char *user_input;
extern Token *token;

/**
 * Abstract Syntax Tree
 */

typedef enum {
  ND_ADD, // +
  ND_SUB, // -
  ND_MUL, // *
  ND_DIV, // /
  ND_EQ,  // ==
  ND_NE,  // !=
  ND_LT,  // <
  ND_LE,  // <=
  ND_NUM, // Number
} NodeKind;

typedef struct Node Node;

struct Node {
  NodeKind kind;
  Node *lhs;     // left hand side
  Node *rhs;     // right hand side
  int val;       // used when kind is ND_NUM
};

Node *expr(void);

void codegen(Node *node);
