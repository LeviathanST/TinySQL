#include "hash_table.h"
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
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
void soul_find_a_with_name(char *name) {
  Person *p;
  FILE *p_file = fopen(PATH, "rb");
  char format[] = "%s - %d\n";
  if (!p_file) {
    printf("Cannot open souls data file: %s", strerror(errno));
    return;
  }

  rewind(p_file);
  short curr_total;
  fread(&curr_total, 2, 1, p_file);

  ht *p_ht = ht_create(curr_total);
  Person *buffer = calloc(curr_total, sizeof(Person));
  fseek(p_file, 2, SEEK_SET);
  fread(buffer, sizeof(Person), curr_total, p_file);

  for (int i = 0; i < curr_total; i++) {
    p = malloc(sizeof(Person));
    strcpy((char *)p->name, (char *)buffer[i].name);
    p->age = buffer[i].age;
    if (!ht_insert(p_ht, buffer[i].name, p)) {
      printf("Something went wrong when insert in hash table!");
      return;
    }
  }
  free(buffer);
  free(p);

  printf("---\n");
  Person *result = (Person *)ht_get(p_ht, name);
  printf("Name: %s\n", result->name);
  printf("Age: %u\n", result->age);
  printf("---\n");

  fclose(p_file);
  ht_clear(p_ht);
}
