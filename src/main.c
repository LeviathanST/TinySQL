#include <stdbool.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#include "soul.h"
#define PATH "./souls"

int main() {
  soul_init(PATH);
  while (true) {
    printf("1: Add\n");
    printf("2: Get All\n");
    printf("3: Find a\n");

    int choice;
    scanf("%d", &choice);
    switch (choice) {
    case 1: {
      Person *p = malloc(sizeof(Person));

      printf("Type name:");
      scanf("%s", p->name);

      printf("Type age:");
      scanf("%d", &p->age);

      soul_write_a(PATH, p);
      break;
    }
    case 2: {
      ResultSet *rs = soul_read_all(PATH);
      char format[] = "%s - %u\n";

      printf("----------\n");
      printf("Total: %u\n", rs->count);
      printf("----------\n");
      if (!rs->count) {
        printf("Empty\n");
      } else {
        for (int i = 0; i < rs->count; i++) {
          Person p = ((Person *)rs->p_rows)[i];
          printf(format, p.name, p.age);
        }
      }
      printf("----------\n");
      free(rs);
      break;
    }
    case 3: {
      Person *p;
      char name[20];
      printf("Type name: \n");
      scanf("%s", name);

      p = soul_find_a_with_name(PATH, name);
      if (!p) {
        break;
      }
      printf("----------\n");
      printf("Name: %s\n", p->name);
      printf("Age: %u\n", p->age);
      printf("----------\n");
      break;
    }
    default:
      break;
    }
  }
  return 0;
}
