#include <errno.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

#include "soul.h"

void soul_init() {
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
  }
}

void soul_increase_curr_total() {
  FILE *p_file = fopen(PATH, "rb+");
  if (!p_file) {
    printf("Cannot open souls data file: %s", strerror(errno));
    return;
  }

  rewind(p_file);
  short curr_total;
  fread(&curr_total, 2, 1, p_file);
  curr_total++;
  rewind(p_file);
  fwrite(&curr_total, 2, 1, p_file);

  fclose(p_file);
}

void soul_write_a(Person *p) {
  FILE *p_file = fopen(PATH, "ab");

  if (!p_file) {
    printf("Cannot open souls data file: %s", strerror(errno));
    return;
  }
  fwrite(p, sizeof(Person), 1, p_file);

  fclose(p_file);
  soul_increase_curr_total();
}

void soul_read_all() {
  FILE *p_file = fopen(PATH, "rb");
  char format[] = "%s - %d\n";
  if (!p_file) {
    printf("Cannot open souls data file: %s", strerror(errno));
    return;
  }

  rewind(p_file);
  short curr_total;
  fread(&curr_total, 2, 1, p_file);

  Person buffer[curr_total];
  fseek(p_file, 2, SEEK_SET);
  fread(buffer, sizeof(Person), curr_total, p_file);

  printf("Total: %d\n", curr_total);
  printf("---\n");
  for (int i = 0; i < curr_total; i++) {
    printf(format, buffer[i].name, buffer[i].age);
  }
  printf("---\n");
  fclose(p_file);
}
