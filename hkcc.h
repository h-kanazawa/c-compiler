#include <assert.h>
#include <ctype.h>
#include <stdarg.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct Type Type;

/*********************************
 * tokenize.c
 *********************************/

typedef enum {
  TK_RESERVED, // operator
  TK_IDENT,    // identity
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
void error_tok(Token *tok, char *fmt, ...);
Token *peek(char *s);
Token *consume(char *op);
char *strndup(char *p, int len);
Token *consume_ident();
void expect(char *op);
int expect_number(void);
char *expect_ident();
bool at_eof(void);
Token *new_token(TokenKind kind, Token *cur, char *str, int len);
Token *tokenize(void);

extern char *user_input;
extern Token *token;


/*********************************
 * parse.c
 *********************************/

typedef struct Var Var;

struct Var {
  char *name;
  Type *ty;
  bool is_local;

  // local variable
  int offset;
};

typedef struct VarList VarList;
struct VarList {
  VarList *next;
  Var *var;
};

// Abstract Syntax Tree
typedef enum {
  ND_ADD,       // +
  ND_SUB,       // -
  ND_MUL,       // *
  ND_DIV,       // /
  ND_EQ,        // ==
  ND_NE,        // !=
  ND_LT,        // <
  ND_LE,        // <=
  ND_NUM,       // Number
  ND_ASSIGN,    // =
  ND_VAR,       // local variable
  ND_RETURN,    // "return"
  ND_IF,        // "if"
  ND_WHILE,     // "while"
  ND_FOR,       // "for"
  ND_BLOCK,     // "{" ... "}"
  ND_FUNCALL,   // Function call
  ND_EXPR_STMT, // Expression statement
  ND_ADDR,      // unary &
  ND_DEREF,     // unary *
  ND_NULL,      // Empty statement
  ND_SIZEOF,    // sizeof
} NodeKind;

typedef struct Node Node;

struct Node {
  NodeKind kind;
  Type *ty;      // Type, e.g. int or pointer to int
  Node *next;    // next node
  Token *tok;    // representative token
  Node *lhs;     // left hand side
  Node *rhs;     // right hand side

  // "if", "while" or "for" statement
  Node *cond;
  Node *then;
  Node *els;
  Node *init;
  Node *inc;

  // Block
  Node *body;

  // Function call
  char *funcname;
  Node *args;

  int val;       // used when kind is ND_NUM
  Var *var;     // variable name when kind is ND_VAR
};

typedef struct Function Function;
struct Function {
  Function *next;
  char *name;
  Node *node;
  VarList *params;
  VarList *locals;
  int stack_size;
};

typedef struct {
  VarList *globals;
  Function *fns;
} Program;

Program *program();

/*********************************
 * typing.c
 *********************************/

typedef enum { TY_INT, TY_PTR, TY_ARRAY } TypeKind;

struct Type {
  TypeKind kind;
  Type *base;
  int array_size;
};

Type *int_type();
Type *pointer_to(Type *base);
Type *array_of(Type *base, int size);
int size_of(Type *ty);

void add_type(Program *prog);

/*********************************
 * codegen.c
 *********************************/

void codegen(Program *prog);
