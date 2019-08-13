/* ====================================================================== */

%{

typedef struct l_type_struct {	/* lex for var and num */
  char *lex;
} l_type;

typedef struct t_type_struct {	/* type for type_specifier */
  unsigned char type;
} t_type;

/* ====================================================================== */

#include "parser.h"
#include <string.h>

/* ====================================================================== */

#define	ACCEPT(x) return(x)
#define	ACCEPT_LEX(x) \
{ \
  yytext[yyleng] = '\0'; \
  lex = malloc(yyleng + 1); \
  strcpy(lex, yytext); \
  return(x); \
}

/* ====================================================================== */

char *lex;			/* current lexeme of ID or NUM */
int source_line_no = 1;		/* source line number */

/* ====================================================================== */

%}

digit				[0-9]
letter				[a-zA-Z]

%%

...

%%

/* ====================================================================== */
