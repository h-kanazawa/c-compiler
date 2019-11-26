#include "hkcc.h"

char *user_input;
Token *token;

/**
 * Error Handling
 */
void error(char *fmt, ...) {
  va_list ap;
  va_start(ap, fmt);

  vfprintf(stderr, fmt, ap);
  fprintf(stderr, "\n");
  exit(1);
}

void verror_at(char *loc, char *fmt, va_list ap) {
  int pos = loc - user_input;
  fprintf(stderr, "%s\n", user_input);
  fprintf(stderr, "%*s", pos, "");
  fprintf(stderr, "^ ");
  vfprintf(stderr, fmt, ap);
  fprintf(stderr, "\n");
  exit(1);
}

void error_at(char *loc, char *fmt, ...) {
  va_list ap;
  va_start(ap, fmt);
  verror_at(loc, fmt, ap);
}

void error_tok(Token *tok, char *fmt, ...) {
  va_list ap;
  va_start(ap, fmt);
  if (tok)
    verror_at(tok->str, fmt, ap);

  vfprintf(stderr, fmt, ap);
  fprintf(stderr, "\n");
  exit(1);
}

char *strndup(char *p, int len) {
  char *buf = malloc(len + 1);
  strncpy(buf, p, len);
  buf[len] = '\0';
  return buf;
}

Token *peek(char *s) {
  if (token->kind != TK_RESERVED || strlen(s) != token->len || memcmp(token->str, s, token->len))
    return NULL;
  return token;
}

Token *consume(char *op) {
  if (!peek(op))
    return NULL;
  Token *t = token;
  token = token->next;
  return t;
}

Token *consume_ident() {
  if (token->kind != TK_IDENT)
    return NULL;
  Token *t = token;
  token = token->next;
  return t;
}

void expect(char *op) {
  if (!peek(op))
    error_tok(token, "is not \"%s\"", op);
  token = token->next;
}

int expect_number() {
  if (token->kind != TK_NUM)
    error_tok(token, "is not a number");
  int val = token->val;
  token = token->next;
  return val;
}

// Ensure that the current token is TK_IDENT.
char *expect_ident() {
  if (token->kind != TK_IDENT)
    error_tok(token, "expected an identifier");
  char *s = strndup(token->str, token->len);
  token = token->next;
  return s;
}

bool at_eof() {
  return token->kind == TK_EOF;
}

// Make new token and connect to cur
Token *new_token(TokenKind kind, Token *cur, char *str, int len) {
  Token *tok = calloc(1, sizeof(Token));
  tok->kind = kind;
  tok->str = str;
  tok->len = len;
  cur->next = tok;
  return tok;
}

bool startswith(char *p, char *q) {
  return memcmp(p, q, strlen(q)) == 0;
}

bool is_alpha(char c) {
  return ('a' <= c && c <= 'z') || ('A' <= c && c <= 'Z') || c == '_';
}

bool is_alnum(char c) {
  return is_alpha(c) || ('0' <= c && c <= '9');
}

char get_escape_char(char c) {
  switch (c) {
    case 'a': return '\a';
    case 'b': return '\b';
    case 't': return '\t';
    case 'n': return '\n';
    case 'v': return '\v';
    case 'f': return '\f';
    case 'r': return '\r';
    case 'e': return 27;
    case '0': return 0;
    default: return c;
  }
}

Token *read_string_literal(Token *cur, char *start) {
  char *p = start + 1;
  char buf[1024];
  int len = 0;

  for (;;) {
    if (len == sizeof(buf))
      error_at(start, "string literal too large");
    if (*p == '\0')
      error_at(start, "unclosed string literal");
    if (*p == '"')
      break;

    if (*p == '\\') {
      p++;
      buf[len++] = get_escape_char(*p++);
    } else {
      buf[len++] = *p++;
    }
  }

  Token *tok = new_token(TK_STR, cur, start, p - start + 1);
  tok->contents = malloc(len + 1);
  memcpy(tok->contents, buf, len);
  tok->contents[len] = '\0';
  tok->cont_len = len + 1;
  return tok;
}

Token *tokenize() {
  char *p = user_input;
  Token head;
  head.next = NULL;
  Token *cur = &head;

  while (*p) {
    if (isspace(*p)) {
      p++;
      continue;
    }

    // Keyword
    if (startswith(p, "return") && !is_alnum(p[6])) {
      cur = new_token(TK_RESERVED, cur, p, 6);
      p += 6;
      continue;
    }

    if (startswith(p, "if") && !is_alnum(p[2])) {
      cur = new_token(TK_RESERVED, cur, p, 2);
      p += 2;
      continue;
    }

    if (startswith(p, "else") && !is_alnum(p[4])) {
      cur = new_token(TK_RESERVED, cur, p, 4);
      p += 4;
      continue;
    }

    if (startswith(p, "while") && !is_alnum(p[5])) {
      cur = new_token(TK_RESERVED, cur, p, 5);
      p += 5;
      continue;
    }

    if (startswith(p, "for") && !is_alnum(p[3])) {
      cur = new_token(TK_RESERVED, cur, p, 3);
      p += 3;
      continue;
    }

    if (startswith(p, "int") && !is_alnum(p[3])) {
      cur = new_token(TK_RESERVED, cur, p, 3);
      p += 3;
      continue;
    }

    if (startswith(p, "char") && !is_alnum(p[4])) {
      cur = new_token(TK_RESERVED, cur, p, 4);
      p += 4;
      continue;
    }

    if (startswith(p, "sizeof") && !is_alnum(p[6])) {
      cur = new_token(TK_RESERVED, cur, p, 6);
      p += 6;
      continue;
    }

    if (startswith(p, "==") || startswith(p, "!=") ||
        startswith(p, "<=") || startswith(p, ">=")) {
      cur = new_token(TK_RESERVED, cur, p, 2);
      p += 2;
      continue;
    }

    if (strchr("+-*/()<>;={},&[]", *p)) {
      cur = new_token(TK_RESERVED, cur, p++, 1);
      continue;
    }

    if (is_alpha(*p)) {
      char *q = p++;
      while (is_alnum(*p))
        p++;
      cur = new_token(TK_IDENT, cur, q, p - q);
      continue;
    }

    // String literal
    if (*p == '"') {
      cur = read_string_literal(cur, p);
      p += cur->len;
      continue;
    }

    if (isdigit(*p)) {
      cur = new_token(TK_NUM, cur, p, 0);
      char *q = p;
      cur->val = strtol(p, &p, 10);
      cur->len = p - q;
      continue;
    }

    error_at(p, "can not tokenize");
  }

  new_token(TK_EOF, cur, p, 0);
  return head.next;
}
