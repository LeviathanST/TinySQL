#include "../src/hash_table.h"
#include "../src/soul.h"
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void test_hash_func() {
  assert(ht_hash("Bob") % 4 == 3);
  assert(ht_hash("Bon") % 4 == 3);
  assert(ht_hash("Boy") % 4 == 2);
  assert(ht_hash("Bou") % 4 == 2);

  assert(ht_hash("Alice") % 20 == 18);
}

void test_add_func() {
  ht *p_ht = ht_create(5);
  Person *p = malloc(sizeof(Person));
  strcpy(p->name, "Soul");
  p->age = 29;

  ht_insert(p_ht, "Bob", "Name: Bob");
  assert(strcmp((const char *)ht_get(p_ht, "Bob"), "Name: Bob") == 0);

  ht_insert(p_ht, "Bob", 0);
  assert(ht_get(p_ht, "Bob") == 0);

  ht_insert(p_ht, "Bob", "Name: Bob");
  ht_insert(p_ht, "Bon", "Name: Bon");
  assert(strcmp((const char *)ht_get(p_ht, "Bon"), "Name: Bon") == 0);
  assert(strcmp((const char *)ht_get(p_ht, "Bob"), "Name: Bob") == 0);

  ht_insert(p_ht, "Soul", p);
  Person *result = ht_get(p_ht, "Soul");
  assert(result->age == 29);
  assert(strcmp(result->name, "Soul") == 0);

  ht_clear(p_ht);
}

int main() {
  test_hash_func();
  test_add_func();
  return 0;
}
