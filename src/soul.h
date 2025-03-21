#ifndef _SOUL_H
#define _SOUL_H

#define PATH "./souls"
#define DEFAULT_TOTAL 0

typedef struct Person Person;
struct Person {
  char name[256];
  int age;
};

/// Init new data file if not exists
void soul_init();

/// Write a soul to data file. Init new data file if not exists
void soul_write_a(Person *p);

/// Get all souls
void soul_read_all();

void soul_find_a_with_name(char *name);

#endif
