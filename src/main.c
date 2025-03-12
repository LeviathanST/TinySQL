#include <errno.h>
#include <stdbool.h>
#include <stddef.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

#define PATH "./souls"
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
    short default_total = DEFAULT_TOTAL;
    fwrite(&default_total, 2, 1, p_file);
    fclose(p_file);
    return;
  }
}

void increase_curr_total() {
  FILE *p_file = fopen(PATH, "rb+");
  if (!p_file) {
    printf("Cannot open souls data file: %s", strerror(errno));
    return;
  }

  int curr_total;

  rewind(p_file);
  fread(&curr_total, 2, 1, p_file);
  curr_total++;
  rewind(p_file);
  fwrite(&curr_total, 2, 1, p_file);

  fclose(p_file);
}

void write_a_soul(Person *p) {
  FILE *p_file = fopen(PATH, "ab");

  if (!p_file) {
    printf("Cannot open souls data file: %s", strerror(errno));
    return;
  }
  fwrite(p, sizeof(Person), 1, p_file);

  fclose(p_file);
  increase_curr_total();
}

int main() {
  init();
  while (true) {
    printf("1: Add\n");
    printf("2: Get All\n");

    int choice;
    scanf("%d", &choice);
    switch (choice) {
    case 1: {
      Person p;

      printf("Type name:");
      scanf("%s", p.name);

      printf("Type age:");
      scanf("%d", &p.age);

      write_a_soul(&p);
      break;
    }
    case 2:
      // Function to read all souls
      break;
    default:
      break;
    }
  }
  return 0;
}
