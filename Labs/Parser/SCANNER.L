/* ====================================================================== */

%{

#include "parser.h"
#include <string.h>
unsigned int source_line_no = 1;

/* ====================================================================== */

#define	ACCEPT(x) return(x)
#define	ACCEPT_LEX(x) \
{ \
  yytext[yyleng] = '\0'; \
  lex = malloc(yyleng + 1); \
  strcpy(lex, yytext); \
  return(x); \
}
#define LINEPLUS(){source_line_no += 1;}

/* ====================================================================== */

char *lex;			/* current lexeme of ID or NUM */

/* ====================================================================== */

%}

digit				[0-9]
letter				[a-zA-Z]
ids				([a-zA-Z]|["_"])([a-zA-Z]|[0-9]|["_"])*
ubar				("_")
commentsend2			([^\n]*"*/")
commentswitchline		("/*"[^\n]*)
comslash                        ("//"[^\n]*)
space                           (" "+)
tap                             ("\t"|"\r")
undefined                       (["`"]|["~"]|["!"]|["@"]|["#"]|["$"]|["%"]|["^"]|["&"]|["|"]|["\\"]|["."]|[":"]|["'"]|["\""])
nline                           ("\n")

%%

"void"				ACCEPT(VOID);
"int"                           ACCEPT(INT);
"if"                            ACCEPT(IF);
"else"                          ACCEPT(ELSE);
"while"                         ACCEPT(WHILE);
"input"                         ACCEPT(INPUT);
"output"                        ACCEPT(OUTPUT);
"return"                        ACCEPT(RETURN);
"+"                             ACCEPT(PLUS);
"-"                             ACCEPT(MINUS);
"*"                             ACCEPT(MULTIPLY);
"/"                             ACCEPT(DIVIDE);
"<"                             ACCEPT(LT);
"<="                            ACCEPT(LE);
">"                             ACCEPT(GT);
">="                            ACCEPT(GE);
"=="                            ACCEPT(EQ);
"!="                            ACCEPT(NE);
"="                             ACCEPT(ASSIGN);
","                             ACCEPT(COMMA);
";"                             ACCEPT(SEMICOLON);
"("                             ACCEPT(LPAR);
")"                             ACCEPT(RPAR);
"{"                             ACCEPT(LBRACE);
"}"                             ACCEPT(RBRACE);
"["                             ACCEPT(LBRACKET);
"]"                             ACCEPT(RBRACKET);
"\""                            ACCEPT(UNDEFINED);
{ids}                           ACCEPT(ID);
{digit}{digit}*                 ACCEPT(NUM);
{commentswitchline}             {}
{commentsend2}                  {}
{comslash}                      {}
{space}				{}
{undefined}                     ACCEPT(UNDEFINED);
{nline}                         {LINEPLUS();}


%%

/* ====================================================================== */
