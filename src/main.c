#include <stdbool.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#include "soul.h"

int main() {
  soul_init();
  while (true) {
    printf("1: Add\n");
    printf("2: Get All\n");

    int choice;
    scanf("%d", &choice);
    switch (choice) {
    case 1: {
      Person *p = malloc(sizeof(Person));

      printf("Type name:");
      scanf("%s", p->name);

      printf("Type age:");
      scanf("%d", &p->age);

      soul_write_a(p);
      break;
    }
    case 2:
      soul_read_all();
      break;
    case 3:
      char name[20];
      printf("Type name: \n");
      scanf("%s", name);
      soul_find_a_with_name(name);
      break;
    default:
      break;
    }
  }
  return 0;
}
