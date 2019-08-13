/* ====================================================================== */

%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include "symbol.c"

/* ====================================================================== */

extern FILE *yyin;		/* FILE * for input file */
extern char *yytext;		/* current lexeme is stored here */

extern char *lex;		/* lexeme of ID and NUM from scanner */
extern int source_line_no;	/* souce line number */

/* ====================================================================== */

int position = 0;			/* current symbol's kind */
char fno[5];
int global_offset;		/* global variable offset */
int local_offset;		/* local variable offset */
int *current_offset;		/* current offset pointer */

int farg_count;			/* no of formal args in function declaration */
int aarg_count;			/* no of actual args in function call */

unsigned int ip = 0;		/* instruction pointer */
/* ====================================================================== */
int error(char *fmt, char *s1, char *s2, char *s3, char *s4, char *s5);
int yyerror(char *message);
int yylex(void);
/* ====================================================================== */

typedef struct l_type_struct {	/* lex attribute for var and num */
  char *lex;
} l_type;

typedef struct t_type_struct {	/* type attribute for type_specifier */
  unsigned char type;
} t_type;

%}

/* ====================================================================== */

%start program

%union {
  l_type lval;
  t_type tval;
}

%token VOID INT
%token IF ELSE WHILE RETURN
%token INPUT OUTPUT
%token PLUS MINUS MULTIPLY DIVIDE
%token LT LE GT GE EQ NE
%token ASSIGN
%token SEMICOLON COMMA
%token LPAR RPAR LBRACKET RBRACKET LBRACE RBRACE
%token ID NUM
%token UNDEFINED

%type <lval> var num
%type <tval> type_specifier

%%

/* ====================================================================== */

program : 
  {
   position=GLOBAL;
   current_table=global_table=create_table("_global");
   current_offset=&global_offset;
   *current_offset=0;
   local_table=create_table(""); //local table 탐색 segmentation fault 방지
  fprintf(stdout,
	"---------- ---------- ---------- ---------- ---------- ----------\n");
  fprintf(stdout,
        "table      symbol     kind       type             size     offset\n");
  fprintf(stdout,
	"---------- ---------- ---------- ---------- ---------- ----------\n");
  }
var_declaration_list fun_declaration_list
  {
   print_table(global_table);
  fprintf(stdout,
	"---------- ---------- ---------- ---------- ---------- ----------\n");
  }
;

var_declaration_list
  : var_declaration_list var_declaration
  | empty
;

fun_declaration_list
  : fun_declaration_list fun_declaration
  | fun_declaration
;

var_declaration : type_specifier var SEMICOLON
  {
   if($<tval>1.type == VOID_TYPE){
     error("error %s: %s %s%s%s",fno ,"wrong void","variable \"" ,$<lval>2.lex,"\"");
   }   
   else if(($<tval>1.type != VOID_TYPE) && ($<tval>1.type != INT_TYPE)){
     error("error %s: %s %s%s%s",fno ,"type error","variable \"" ,$<lval>2.lex,"\"");
    }
   else {
     struct symbol *symbolp;
     symbolp = lookup_symbol($<lval>2.lex);
     if(symbolp == NULL){
       add_symbol(current_table, $<lval>2.lex, position, $<tval>1.type,1, // 일반변수심볼
       *current_offset);
       *current_offset = *current_offset + 1;
     }
     else{
      error("error %s: %s %s%s%s",fno ,"redefined","variable \"" ,$<lval>2.lex,"\"");}
   }
  }
  | type_specifier var LBRACKET num RBRACKET SEMICOLON
  {
     if($<tval>1.type == VOID_TYPE){
       error("error %s: %s %s%s%s",fno ,"wrong void","array \"" ,$<lval>2.lex,"\"");
     }   
     else if($<tval>1.type != VOID_TYPE && $<tval>1.type != INT_TYPE){
       error("error %s: %s %s%s%s",fno ,"type error","array \"" ,$<lval>2.lex,"\"");
     }
     else{
       struct symbol *symbolp;
       symbolp = lookup_symbol($<lval>2.lex);
         if(symbolp == NULL){
           int n = atoi($<lval>4.lex);
           add_symbol(current_table, $<lval>2.lex, position, INT_ARRAY_TYPE,
           n, *current_offset + n - 1); // 배열변수심볼입력. offset에 주의
           *current_offset = *current_offset + n;
         }
         else{
           error("error %s: %s %s%s%s",fno ,"redefined","array \"" ,$<lval>2.lex,"\"");
         }
     }
  }
;

type_specifier
  : INT
  {
   $<tval>$.type=INT_TYPE;
  }
  | VOID
  {
   $<tval>$.type=VOID_TYPE;
  }
;

var
  : ID
  {
   $<lval>$.lex=lex;
  }
;

num 
  : NUM
  {
   $<lval>$.lex = lex;
  }
;

fun_declaration  
  : type_specifier var 
  {  
    if(($<tval>1.type != VOID_TYPE) &&( $<tval>1.type != INT_TYPE)){
      error("error %s: %s %s%s%s",fno ,"type error","function \"" ,$<lval>2.lex,"\"");
    }
  
       farg_count = 0;
       position = ARGUMENT;
       current_table= local_table = create_table($<lval>2.lex); // 지역테이블을 생성
       current_offset = &local_offset;
       *current_offset = 0;

  }
  LPAR params RPAR
  {
       struct symbol *symbolp;
       symbolp = lookup_symbol($<lval>2.lex);
       if(symbolp == NULL){
         add_symbol(global_table, $<lval>2.lex, FUNCTION, $<tval>1.type, farg_count, ip); //함수심볼->전역테이블입력
        }
        else{
          error("error %s: %s %s%s%s",fno,"redefined","function \"",$<lval>2.lex,"\"");
  }
  position=LOCAL; 
  }
  LBRACE local_declarations statement_list RBRACE
  {
   print_table(current_table);  // 지역 테이블을 출력함
  fprintf(stdout,
	"---------- ---------- ---------- ---------- ---------- ----------\n");
  }
;

params
  : param_list
  | VOID
;

param_list
  : param_list COMMA param
  {
   farg_count++; // 형식인수의 개수를 계산하는변수
  }
  | param
  {
   farg_count = 1;
  }
;

param : type_specifier var
  {
     if($<tval>1.type == VOID_TYPE){
       error("error %s: %s %s%s%s",fno ,"wrong void","argument \"" ,$<lval>2.lex,"\"");
     }
     else{
       struct symbol *symbolp;
       symbolp = lookup_symbol($<lval>2.lex);
         if(symbolp == NULL){
           add_symbol(current_table, $<lval>2.lex, position, $<tval>1.type, 1, *current_offset);
           *current_offset = *current_offset + 1;
        // printf("%08x : %s has been created\n",symbolp, symbolp->name);
         }
         else{
           error("error %s: %s %s%s%s",fno ,"redefined","argument \"" ,$<lval>2.lex,"\"");
         }
     }
  }
  | type_specifier var LBRACKET RBRACKET
  {                  // 배열변수심볼입력
     if($<tval>1.type == VOID_TYPE){
       error("error %s: %s %s%s%s",fno ,"wrong void","array argument \"" ,$<lval>2.lex,"\"");
     }
     else{
       struct symbol *symbolp;
       symbolp = lookup_symbol($<lval>2.lex);
         if(symbolp == NULL){
           add_symbol(current_table, $<lval>2.lex, position, INT_P_TYPE, 1, *current_offset);
           *current_offset = *current_offset + 1;
         }
         else{
           error("error %s: %s %s%s%s",fno ,"redefined","array argument \"" ,$<lval>2.lex,"\"");
         }
     }
  }
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

expression : var ASSIGN expression
  {
   struct symbol *symbolp;
   symbolp = lookup_symbol($<lval>1.lex);
     if(symbolp == NULL){
       error("error %s: %s %s%s%s", fno,"undefined", "variable \"",$<lval>1.lex,"\"");
     }
     else if(symbolp->kind == FUNCTION) {
       error("error %s: %s %s%s%s", fno,"type error", "variable \"",$<lval>1.lex,"\"");
     }
  }
  | var LBRACKET expression RBRACKET ASSIGN expression
  {
   struct symbol *symbolp;
   symbolp = lookup_symbol($<lval>1.lex);
     if(symbolp == NULL){
       error("error %s: %s %s%s%s", fno,"undefined", "array \"",$<lval>1.lex,"\"");
     }
     else if(symbolp->kind == FUNCTION || symbolp->kind == FUNCTIONI) {
       error("error %s: %s %s%s%s", fno,"type error", "array \"",$<lval>1.lex,"\"");
     }  
  }
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
  {
   struct symbol *symbolp;
   symbolp = lookup_symbol($<lval>1.lex);
   if(symbolp == NULL)
   error("error %s: %s %s%s%s", fno,"undefined", "variable \"", $<lval>1.lex,"\"");
  }  
  | var LBRACKET expression RBRACKET
  {
   struct symbol *symbolp;
   symbolp = lookup_symbol($<lval>1.lex);
   if(symbolp == NULL)
   error("error %s: %s %s%s%s", fno,"undefined", "array \"", $<lval>1.lex,"\"");
  }
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
  {
   char *var = $<lval>1.lex;
   struct symbol *symbolp;
   symbolp = lookup_symbol(var);
    if(symbolp==NULL){
       error("error %s: %s %s%s%s", fno,"undefined", "variable \"",$<lval>1.lex,"\"");
    }
  }
  | var LBRACKET expression RBRACKET ASSIGN call
  | call
;

call
  : var
  {
   struct symbol *symbolp;
   symbolp = lookup_symbol($<lval>1.lex); // 함수심볼을 사용함
     if(symbolp == NULL){
       error("error %s: %s %s%s%s", fno,"undefined function", "call \"", $<lval>1.lex,"\"");
    }
     else if(symbolp->kind != FUNCTION){
       error("error %s: %s %s%s%s", fno,"type error", "function \"",$<lval>1.lex,"\"");
     } 
   aarg_count = 0;
  }
  LPAR args RPAR
  {
   struct symbol *symbolp;
   symbolp = lookup_symbol($<lval>1.lex); // 함수심볼을 사용함
   if(symbolp->size != aarg_count)
   error("error %s: %s %s%s%s", fno,"wrong no argument","function \"", $<lval>1.lex,"\"");
 } 
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
  print_table(current_table);
  fprintf(stdout,
	"---------- ---------- ---------- ---------- ---------- ----------\n");
  print_table(global_table);
  fprintf(stdout,
	"---------- ---------- ---------- ---------- ---------- ----------\n");
  fprintf(stderr, "line %d: %s at \"%s\"\n", source_line_no, message,
	  yytext);
}

/* ====================================================================== */

int error(char *fmt, char *s1, char *s2, char *s3, char *s4,char *s5)
{
  print_table(current_table);
  fprintf(stdout,
	"---------- ---------- ---------- ---------- ---------- ----------\n");
  print_table(global_table);
  fprintf(stdout,
	"---------- ---------- ---------- ---------- ---------- ----------\n");
  fprintf(stdout, "line %d: ", source_line_no);
  fprintf(stdout, fmt, s1, s2, s3, s4, s5);
  fprintf(stdout, "\n");
  fflush(stdout);
  exit(1);
}

/* ====================================================================== */

int main(int argc, char *argv[])
{
  if(argc != 2) {
    fprintf(stderr, "usage: symbol file\n");
    exit(1);
  }
  yyin = fopen(argv[1], "r");
  fno[0] =argv[1][6];
  fno[1] =argv[1][7];
  if(yyin == NULL) {
    fprintf(stderr, "%s: %s\n", argv[1], strerror(errno));
    exit(1);
  }
  yyparse();

  return 0;
}

/* ====================================================================== */
