// ======================================================================
// Sample Deterministic Finite Automaton
// ======================================================================

#include <stdio.h>
#include <stdlib.h>
#include <readline/readline.h>
#include <readline/history.h>

// ======================================================================
// A DFA is described here!
// ======================================================================

#define NO_OF_ALPHABET 3 
#define NO_OF_STATES 4

char alphabet[NO_OF_ALPHABET] = { 'x', 'y','z' };	// symbol must be char constant

int starting_state = 0;
int accepting_states[NO_OF_STATES] = { 0,0,0,1 };	// 1 means accepting state

int transition_function[NO_OF_STATES][NO_OF_ALPHABET] = {
  {1, 0, 0},
  {2, 0, 0},
  {3, 0, 0},
  {3, 3, 3}
};

// ======================================================================
// Do not modify any line below!
// ======================================================================

#define BUFFER_LENGTH 1024

#define ACCEPT 1
#define REJECT 0

// ======================================================================

int symbol_index(char c)
{
  int i;

  for (i = 0; i < NO_OF_ALPHABET; i++)
    if (alphabet[i] == c)
      return i;
  fflush(stdout);
  fprintf(stderr, "fatal: undefined symbol '%c'\n", c);
  exit(-1);
}

// ======================================================================

int dfa(char input_string[])
{
  char c;
  int i = 0, state = starting_state;

  for (;;) {
    c = input_string[i++];
    if (c == '\0') {
      if (accepting_states[state] == 1)
	return ACCEPT;
      else
	return REJECT;
    } else
      state = transition_function[state][symbol_index(c)];
  }
}

// ======================================================================

int main(void)
{
  char *input_string;

  while ((input_string = readline("")) != NULL)
    if (dfa(input_string) == ACCEPT)
      printf("accept: %s\n", input_string);
    else
      printf("reject: %s\n", input_string);

  return EXIT_SUCCESS;
}

// ======================================================================
