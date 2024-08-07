/* ====================================================================== */

%{


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>

/* ====================================================================== */

extern FILE *yyin;
extern char *yytext;
extern unsigned int source_line_no;

/* ====================================================================== */

int yyerror(char *message);
%}

/* ====================================================================== */

%start program

%token VOID INT IF ELSE WHILE INPUT OUTPUT RETURN PLUS MINUS MULTIPLY DIVIDE LT LE GT GE EQ NE ASSIGN COMMA SEMICOLON LPAR RPAR LBRACE RBRACE LBRACKET RBRACKET 
UNDEFINED ID NUM


%%

/* ====================================================================== */

program
  : var_declaration_list fun_declaration_list
;

var_declaration_list
  : var_declaration_list var_declaration
  | empty
;

fun_declaration_list
  : fun_declaration_list fun_declaration
  | fun_declaration
;

var_declaration
  : type_specifier var SEMICOLON
  | type_specifier var LBRACKET num RBRACKET SEMICOLON
;

type_specifier
  : INT
  | VOID
;

var
  : ID
;

num
  : NUM
;

fun_declaration
  : type_specifier var LPAR params RPAR LBRACE local_declarations statement_list RBRACE
;

params
  : param_list
  | VOID
;

param_list
  : param_list COMMA param
  | param
;

param
  : type_specifier var
  | type_specifier var LBRACKET RBRACKET
;

local_declarations
  : local_declarations var_declaration
  | empty
;

statement_list
  : statement_list statement
  | empty
;

statement
  : compound_stmt
  | expression_stmt
  | selection_stmt
  | iteration_stmt
  | funcall_stmt
  | return_stmt
  | input_stmt
  | output_stmt
;

compound_stmt
  : LBRACE statement_list RBRACE
;

expression_stmt
  : expression SEMICOLON
  | SEMICOLON
;

expression
  : var ASSIGN expression
  | var LBRACKET expression RBRACKET ASSIGN expression
  | simple_expression
;

simple_expression
  : additive_expression relop additive_expression
  | additive_expression
;

relop
  : LT | LE | GT | GE | EQ | NE
;

additive_expression
  : additive_expression addop term
  | term
;

addop
  : PLUS | MINUS
;

term
  : term mulop factor
  | factor
;

mulop
  : MULTIPLY | DIVIDE
;

factor
  : LPAR expression RPAR
  | var
  | var LBRACKET expression RBRACKET
  | num
  | PLUS num
  | MINUS num
;

selection_stmt
  : IF LPAR expression RPAR statement ELSE statement
;

iteration_stmt
  : WHILE LPAR expression RPAR statement
;

funcall_stmt
  : var ASSIGN call
  | var LBRACKET expression RBRACKET ASSIGN call
  | call
;

call
  : var LPAR args RPAR
;

args
  : arg_list
  | empty
;

arg_list
  : arg_list COMMA expression
  | expression
;

return_stmt
  : RETURN SEMICOLON
  | RETURN expression SEMICOLON
;

input_stmt
  : INPUT var SEMICOLON
  | INPUT var LBRACKET expression RBRACKET SEMICOLON
;

output_stmt
  : OUTPUT expression SEMICOLON
;

empty
  :
;




%%

/* ====================================================================== */

int yyerror(char *message)
{
  fprintf(stderr, "line %d: %s at \"%s\"\n", source_line_no, message, yytext);
}

/* ====================================================================== */

int main(int argc, char *argv[])
{
  if(argc != 2) {
    fprintf(stderr, "usage: parser file\n");
    exit(1);
  }
  yyin = fopen(argv[1], "r");
  if(yyin == NULL) {
    fprintf(stderr, "%s: %s\n", argv[1], strerror(errno));
    exit(1);
  }
  yyparse();

  return 0;
}

/* ====================================================================== */
