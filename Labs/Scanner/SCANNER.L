/* ====================================================================== */
%{

#include <stdio.h>
int source_line_no = 1;
int f = 1;
#define ACCEPT(x){if(f==2)f=1;if(f == 1)printf("line=%i, token=%s, lexeme=\"%s\"\n", source_line_no,(char *)x, yytext);fflush(stdout);}
#define LINEPLUS(){source_line_no += 1;}
%}
digit				[0-9]
letter				[a-zA-Z]
ids				([a-zA-Z]|["_"])([a-zA-Z]|[0-9]|["_"])*
ubar				("_")
commentsend2			([^\n]*"*/")
commentswithline		("/*"[^\n]*)
comslash			("//"[^\n]*)
space				(" "+)
tap				("\t"|"\r")
undefined			(["`"]|["~"]|["!"]|["@"]|["#"]|["$"]|["%"]|["^"]|["&"]|["|"]|["\\"]|["."]|[":"]|["'"]|["\""])
nline				("\n")
%%
"void"				ACCEPT("VOID");
"int"				ACCEPT("INT");
"if"				ACCEPT("IF");
"else"				ACCEPT("ELSE");
"while"				ACCEPT("WHILE");
"input"				ACCEPT("INPUT");
"output"			ACCEPT("OUTPUT");
"return"			ACCEPT("RETURN");
"+"				ACCEPT("PLUS");
"-"				ACCEPT("MINUS");
"*"				ACCEPT("MULTIPLY");
"/"				ACCEPT("DIVIDE");
"<"				ACCEPT("LT");
"<="				ACCEPT("LE");
">"				ACCEPT("GT");
">="				ACCEPT("GE");
"=="				ACCEPT("EQ");
"!="				ACCEPT("NE");
"="				ACCEPT("ASSIGN");
","				ACCEPT("COMMA");
";"				ACCEPT("SEMICOLON");
"("				ACCEPT("LPAR");
")"				ACCEPT("RPAR");
"{"				ACCEPT("LBRACE");
"}"				ACCEPT("RBRACE");
"["				ACCEPT("LBRACKET");
"]"				ACCEPT("RBRACKET");
"\""				ACCEPT("UNDEFINED");
{ids}				ACCEPT("ID");
{digit}{digit}*			ACCEPT("NUM");
{commentswithline}		{f = 0;}
{commentsend2}			{f = 2;}
{comslash}			{}
{tap}				{f = 2;}
{space}				{f = 2;}
{undefined}			ACCEPT("UNDEFINED");
{nline}				{f = 2;LINEPLUS();}
%%

/* ====================================================================== */


int main(int argc, char *argv[])
{
  if(argc != 2) {
    fprintf(stderr, "usage: scanner file\n");
    exit(1);
  }
  yyin = fopen(argv[1], "r");
  if(yyin == NULL) {
    fprintf(stderr, "%s: %s\n", argv[1], strerror(errno));
    exit(1);
  }
  yylex();

  return 0;
}

/* ====================================================================== */
