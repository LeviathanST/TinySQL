#include <errno.h>
#include <stdbool.h>
#include <stddef.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

#define PATH "/path/to/data/file"
#define DEFAULT_TOTAL 0

typedef struct {
  char name[20];
  int age;
} Person;

// NOTE: Init data file if not exists
void init() {
  int is_exists = access(PATH, F_OK);
  if (is_exists == -1) {
    FILE *p_file = fopen(PATH, "wb+");
    if (p_file == NULL) {
      printf("Cannot init data file for souls: %s", strerror(errno));
      return;
    }
    int default_total = DEFAULT_TOTAL;
    fwrite(&default_total, 2, 1, p_file);
    fclose(p_file);
    return;
  }

  printf("Data file is exists!");
}

int main() {
  init();
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
