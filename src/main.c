#include <stdbool.h>
#include <stddef.h>
#include <stdio.h>

typedef struct {
  char name[20];
  int age;
} Person;

int main() {
  while (true) {
    printf("1: Add\n");
    printf("2: Get All\n");

    int choice;
    scanf("%d", &choice);
    switch (choice) {
    case 1:
      // Function to write a soul
      break;
    case 2:
      // Function to read all souls
      break;
    default:
      break;
    }
  }
  return 0;
}
