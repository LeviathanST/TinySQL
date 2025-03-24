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
    FILE *p_file = fopen(path, "ab");
    if (p_file == NULL) {
      printf("Cannot init data file for souls: %s\n", strerror(errno));
      return 0;
    }

    /* 2 bytes - the number of current total entities
     * 512 bytes - the index area
     * 512 bytes - the data area
     * */
    unsigned char *buffer = calloc(1, 1026);
    fwrite(buffer, 514, 1, p_file);

    fclose(p_file);
  }
  return 1;
}

/* This function will write entity's index into the index area then increasing
 * the number of current total entites.
 **/
void soul_write_index_and_increase_curr_total(const char *path, char key[8]) {
  FILE *p_file = fopen(path, "rb+");
  Index i;
  if (!p_file) {
    printf("Cannot open souls data file: %s", strerror(errno));
    return;
  }
  // Read and increase the current total in data file
  short curr_total;
  fread(&curr_total, 2, 1, p_file);
  if (curr_total * 12 > 512) {
    printf("The index area is full! %u", curr_total);
    return;
  }

  strncpy(i.key, key, 8);
  i.offset = (unsigned int)(curr_total * sizeof(Person));

  // Go to n-th index in the index area from the beginning
  // 0 -> 1   - the number of current total (skip)
  // n -> (n + 12) - 1 (n = the previous ended value + 1)
  // 2 -> 13  - the first entity
  // 14 -> 25 - the second entity
  fseek(p_file, 2 + curr_total * (sizeof(char *) + sizeof(unsigned int)),
        SEEK_SET);
  fwrite(i.key, sizeof(char *), 1, p_file);
  fwrite(&i.offset, sizeof(unsigned int), 1, p_file);

  curr_total++;
  rewind(p_file);
  fwrite(&curr_total, 2, 1, p_file);

  fclose(p_file);
}

int soul_write_a(const char *path, Person *p) {
  soul_write_index_and_increase_curr_total(path, p->name);
  FILE *p_file = fopen(path, "ab");

  if (!p_file) {
    printf("Cannot open souls data file: %s\n", strerror(errno));
    return 0;
  }

  fwrite(p, sizeof(Person), 1, p_file);
  fclose(p_file);
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
  fseek(p_file, 514, SEEK_SET);
  fread(buffer, sizeof(Person), curr_total, p_file);

  rs->count = curr_total;
  rs->p_rows = buffer;

  fclose(p_file);
  return rs;
}

Person *soul_find_a_with_name(const char *path, const char *name) {
  FILE *p_file = fopen(path, "rb");
  if (!p_file) {
    printf("Cannot open souls data file: %s", strerror(errno));
    return 0;
  }

  rewind(p_file);
  short curr_total;
  fread(&curr_total, 2, 1, p_file);

  ht *p_ht = ht_create(curr_total);
  Index *index = calloc(12, curr_total);
  fseek(p_file, 2, SEEK_SET);
  fread(index, sizeof(Index), curr_total, p_file);

  for (int i = 0; i < curr_total; i++) {
    ht_insert(p_ht, index[i].key, &index[i].offset);
  }

  unsigned int *offset = ht_get(p_ht, name);
  if (!offset) {
    printf("Not Found!\n");
    return 0;
  }
  Person *p = malloc(sizeof(Person));
  fseek(p_file, 514 + *offset, SEEK_SET);
  fread(p, sizeof(Person), 1, p_file);

  free(index);
  fclose(p_file);
  ht_clear(p_ht);
  return p;
}
