#ifndef HASH_TABLE_H
#define HASH_TABLE_H

typedef struct HashNode ht_node;
typedef struct HashTable ht;

struct HashNode {
  ht_node *next;
  const char *key;
  void *data;
};
struct HashTable {
  unsigned int size;
  ht_node **node;
};

ht *ht_create(int size);
unsigned int ht_hash(const char *key);
int ht_insert(ht *p_ht, const char *key, void *data);
void *ht_get(ht *p_ht, const char *key);
void ht_clear(ht *p_ht);
#endif
