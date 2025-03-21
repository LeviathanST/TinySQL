#ifndef _SOUL_H
#define _SOUL_H

#define PATH "./souls"
#define DEFAULT_TOTAL 0
typedef struct ResultSet ResultSet;
struct ResultSet {
  unsigned int count;
  void *p_rows; // Rows Array
};

typedef struct Person Person;
struct Person {
  char name[256]; // Unique
  unsigned int age;
};

/// Init new data file if not exists.
int soul_init();

/// Write a soul to data file. Init new data file if not exists.
int soul_write_a(Person *p);

/// Get all souls.
ResultSet *soul_read_all();

/// Return 0 if not exists.
Person *soul_find_a_with_name(char *name);

#endif
