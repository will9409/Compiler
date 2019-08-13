#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define MAX_SIZE 1024
#define SWAP(T,a,b) do {T tmp = a; a = b; b = tmp; } while(0)
typedef struct set{
  char elem[MAX_SIZE];

}Set;


char data[MAX_SIZE][MAX_SIZE];
char tempdata[MAX_SIZE];

 int w = 0;
 int s = 0;

void printer(int n,int r){
    for(int i = 0; i < n; i++){
    printf("%s\n",data[i]);
    }
}

int convert_string(const void *a, const void *b)
{
    return strcmp((char *)a,(char *)b);
}

void process(int r){
    for (int i = r-1; i >= 0; i--){
        data[w][i] = tempdata[i];
    }
}

void perm(Set *set,int n, int r,int q){

   if(r==0){
      process(q);
      w = w + 1;
      return;
   }

   for(int i = 0; i < n; i++){
      SWAP(Set,set[i],set[n-1]);
      tempdata[r-1] = set[n-1].elem[0];
      perm(set,n,r-1,q);
      SWAP(Set,set[i],set[n-1]);
   }
}

void sigma(Set *set,int o, int p, int q){
  int t = p;
  for(int i = 1; i < o; i++){
  t = t*p;
  }
  perm(set,p,o,q);
  qsort(data,t,sizeof(data[0]),convert_string);
  if(o == 1){
    printer(p,o);
  }
  else{
    int x = p;
    for(int i = 1; i < o;i++){
    x = x*p;
    }
    printer(x,o);
  }
  w = 0;

}

int main (int argc, char* argv[]){

Set sets[MAX_SIZE];

int o = atoi(argv[argc-1]);

for(int i = 0; i < argc-2; i++){
   sets[i].elem[0] = *argv[i+1];
   //printf("sets[%d].elem[0] = %s \n",i,sets[i].elem);
}

printf("\n");
 for(int j = 1; j <= o; j++){
    sigma(sets,j,argc-2,o);
 }

}


