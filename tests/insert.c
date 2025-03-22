#include "../src/soul.h"
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define PATH "./build/tests/souls_test"

int main() {
  int size = 5;
  Person *p = calloc(size, sizeof(Person));
  soul_init(PATH);

  strcpy(p[0].name, "Alice");
  p[0].age = 29;
  strcpy(p[1].name, "Bob");
  p[1].age = 29;
  strcpy(p[2].name, "Bon");
  p[2].age = 30;
  strcpy(p[3].name, "Ronin");
  p[3].age = 31;

  for (int i = 0; i < size; i++) {
    if (!soul_write_a(PATH, &p[i])) {
      printf("Test soul insert is failed\n");
      return 0;
    }
  }

  p[0] = *soul_find_a_with_name(PATH, "Alice");
  p[1] = *soul_find_a_with_name(PATH, "Bob");
  p[2] = *soul_find_a_with_name(PATH, "Bon");
  p[3] = *soul_find_a_with_name(PATH, "Ronin");

  assert(strcmp(p[0].name, "Alice") == 0);
  assert(p[0].age == 29);
  assert(strcmp(p[1].name, "Bob") == 0);
  assert(p[1].age == 29);
  assert(strcmp(p[2].name, "Bon") == 0);
  assert(p[2].age == 30);
  // assert(strcmp(p[3].name, "Ronin") == 0);
  // assert(p[3].age == 31);

  free(p);
}
