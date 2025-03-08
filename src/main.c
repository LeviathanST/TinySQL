#include "stdio.h"

int main() {
  char names[3][20] = {"Alice", "Bob"};
  int ages[3] = {30, 31};

  char format[] = "%s - %d\n"; // name - age

  printf(format, names[0], ages[0]);
  printf(format, names[1], ages[1]);
  return 0;
}
