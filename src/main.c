#include <stddef.h>
#include <stdio.h>

int main() {
  char names[3][20] = {"Alice", "Bob"};
  int ages[3] = {30, 31};

  char format[] = "%s - %d\n"; // name - age
  printf("Type a name: \n");
  scanf("%s", names[2]);
  printf("Type a age: \n");
  scanf("%d", &ages[2]);

  printf(format, names[2], ages[2]);
  return 0;
}
