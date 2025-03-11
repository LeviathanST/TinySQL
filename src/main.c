#include <stdbool.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct {
  char name[20];
  int age;
} Person;

int main() {
  int capacity = 4;
  int total = 3;
  Person *p = malloc(sizeof(Person) * capacity);

  char format[] = "%s - %d\n"; // name - age

  strcpy(p[0].name, "Alice");
  p[0].age = 30;

  strcpy(p[1].name, "Bob");
  p[1].age = 31;

  while (true) {
    if (total > capacity) {
      capacity *= 2;
      p = realloc(p, sizeof(Person) * capacity);
    }

    printf("Type name:\n");
    scanf("%s", p[total - 1].name);

    printf("Type age:\n");
    scanf("%d", &p[total - 1].age);

    for (int i = 0; i < total; i++) {
      printf(format, p[i].name, p[i].age);
    }
    total++;
  }
  free(p);
  return 0;
}
