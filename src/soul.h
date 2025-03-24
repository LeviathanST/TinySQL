#ifndef _SOUL_H
#define _SOUL_H

typedef struct Index Index;
typedef struct Index {
  char key[8];
  unsigned int offset;
} Index;

typedef struct ResultSet ResultSet;
struct ResultSet {
  unsigned int count;
  void *p_rows; // Rows Array
};

typedef struct Person Person;
struct Person {
  char name[20]; // Unique
  unsigned int age;
};

/*
 * Path is where database file you want to open.
 * Init new if PATH not exist.
 */
int soul_init(const char *path);

/// Write a soul to data file. Init new data file if not exists.
int soul_write_a(const char *path, Person *p);

/// Get all souls.
ResultSet *soul_read_all(const char *path);

/// Return 0 if not exists.
Person *soul_find_a_with_name(const char *path, const char *name);

#endif
