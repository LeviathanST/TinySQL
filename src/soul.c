#include "hash_table.h"
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "soul.h"

int soul_init(const char *path) {
  int is_exists = access(path, F_OK);
  if (is_exists == -1) {
    FILE *p_file = fopen(path, "wb+");
    if (p_file == NULL) {
      printf("Cannot init data file for souls: %s\n", strerror(errno));
      return 0;
    }
    short default_total = DEFAULT_TOTAL;
    fwrite(&default_total, 2, 1, p_file);
    fclose(p_file);
  }
  return 1;
}

void soul_increase_curr_total(const char *path) {
  FILE *p_file = fopen(path, "rb+");
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

int soul_write_a(const char *path, Person *p) {
  FILE *p_file = fopen(path, "ab");

  if (!p_file) {
    printf("Cannot open souls data file: %s\n", strerror(errno));
    return 0;
  }
  fwrite(p, sizeof(Person), 1, p_file);

  fclose(p_file);
  soul_increase_curr_total(path);
  return 1;
}

ResultSet *soul_read_all(const char *path) {
  FILE *p_file = fopen(path, "rb");
  ResultSet *rs = malloc(sizeof(ResultSet));

  if (!p_file) {
    printf("Cannot open souls data file: %s\n", strerror(errno));
    return 0;
  }

  rewind(p_file);
  short curr_total;
  fread(&curr_total, 2, 1, p_file);

  Person *buffer = calloc(curr_total, sizeof(Person));
  fseek(p_file, 2, SEEK_SET);
  fread(buffer, sizeof(Person), curr_total, p_file);

  rs->count = curr_total;
  rs->p_rows = buffer;

  fclose(p_file);
  return rs;
}

// TODO: Enhance performance
// - Using index
Person *soul_find_a_with_name(const char *path, char *name) {
  FILE *p_file = fopen(path, "rb");
  if (!p_file) {
    printf("Cannot open souls data file: %s", strerror(errno));
    return 0;
  }

  rewind(p_file);
  short curr_total;
  fread(&curr_total, 2, 1, p_file);

  ht *p_ht = ht_create(curr_total);
  Person *buffer = calloc(curr_total, sizeof(Person));
  fseek(p_file, 2, SEEK_SET);
  fread(buffer, sizeof(Person), curr_total, p_file);

  for (int i = 0; i < curr_total; i++) {
    if (!ht_insert(p_ht, buffer[i].name, &buffer[i])) {
      printf("Something went wrong when insert in hash table!");
      return 0;
    }
  }

  Person *result = ht_get(p_ht, name);
  if (!result) {
    printf("Not Found!\n");
    return 0;
  }

  fclose(p_file);
  free(buffer);
  ht_clear(p_ht);
  return result;
}
