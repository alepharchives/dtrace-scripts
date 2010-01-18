#include <sys/mman.h>
#include <fcntl.h>
#include <stdio.h>

static long SIZE = 8589934592L;

int main(int argc, char**argv)
{
  char *result = mmap(0, SIZE, PROT_READ|PROT_WRITE, MAP_ANON|MAP_PRIVATE, -1, 0); 
  if (result != MAP_FAILED)
  {
    unsigned long i;
    
    for (i = 0; i < SIZE; i += 4096)
      result[i] = 1;
    return 0;
  }
  return 1;
}
