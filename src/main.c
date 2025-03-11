#include <stdbool.h>
#include <stddef.h>
#include <stdio.h>

struct Person {
  char name[20];
  int age;
};

int main() {
  struct Person people[100] = {
      {"Alice", 30},
      {"Bob", 31},
  };
  int curr_idx = 2;

  char format[] = "%s - %d\n"; // name - age
  bool out = false;

  while (!out) {
    struct Person p;

    printf("Type name: ");
    scanf("%s", p.name);

    printf("Type age: ");
    scanf("%d", &p.age);

    people[curr_idx] = p;

    for (int i = 0; i <= curr_idx; i++) {
      printf(format, people[i].name, people[i].age);
    }

    curr_idx++;
  }

  return 0;
}
