#ifndef _SOUL_H
#define _SOUL_H

#define PATH "./souls"
#define DEFAULT_TOTAL 0

typedef struct {
  char name[20];
  int age;
} Person;

/// Init new data file if not exists
void soul_init();

/// Write a soul to data file. Init new data file if not exists
void soul_write_a(Person *p);

/// Get all souls
void soul_read_all();

#endif
