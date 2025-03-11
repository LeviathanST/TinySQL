#include <stdbool.h>
#include <stddef.h>
#include <stdio.h>

int main() {
  char names[100][20] = {"Alice", "Bob"};
  int ages[100] = {30, 31};
  int curr_idx = 2;

  char format[] = "%s - %d\n"; // name - age
  bool out = false;

  size_t names_length = sizeof(names) / sizeof(names[0]);
  while (!out) {
    if (curr_idx > names_length) {
      printf("Maximum data amount");
    }
    printf("Type a name: \n");
    scanf("%s", names[curr_idx]);
    printf("Type a age: \n");
    scanf("%d", &ages[curr_idx]);
    printf("The crew: \n");

    for (int i = 0; i <= curr_idx; i++) {
      printf(format, names[i], ages[i]);
    }

    curr_idx++;
  }

  return 0;
}
