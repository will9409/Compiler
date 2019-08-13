/* ====================================================================== */

#include <stdio.h>
#include <stdlib.h>

#define HASH_SIZE	11	/* hash array size */

				/* symbol's kind */
#define GLOBAL		0	/* global variable */
#define LOCAL		1	/* local variable */
#define ARGUMENT	2	/* formal argument */
#define FUNCTION	3	/* function name */
#define FUNCTIONI	4	/* incomplete function */
				/* symbol's type */
#define INT_TYPE	0	/* int type */
#define INT_ARRAY_TYPE	1	/* int array type */
#define INT_P_TYPE	2	/* int [] type */
#define VOID_TYPE	3	/* void type */

/* ====================================================================== */

struct symbol {
  char *name;			/* symbol's name */
  unsigned char kind;		/* symbol's kind */
  unsigned char type;		/* symbol's type */
  unsigned int size;		/* byte size or no of args */
  unsigned int offset;		/* relative memory offset */
  unsigned int ip[128];		/* ip that calls this function */
  unsigned int ipc;		/* ip count in ip[] */
  struct symbol *next;		/* next symbol pointer */
};

struct table {
  char *name;			/* function name */
  struct symbol *hash[HASH_SIZE];	/* hash array */
};

struct table *global_table;	/* global symbol table */
struct table *local_table;	/* local symbol table */
struct table *current_table;	/* current symbol table */

/* ====================================================================== */

...

/* ====================================================================== */
