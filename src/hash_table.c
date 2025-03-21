#include "hash_table.h"
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

ht *ht_create(int size) {
  ht *p_ht = malloc(sizeof(ht));
  if (p_ht == NULL) {
    printf("Cannot allocate hash table: %s", strerror(errno));
    return NULL;
  }

  p_ht->node = calloc(size, sizeof(ht_node *));
  p_ht->size = size;

  return p_ht;
}
unsigned int ht_hash(const char *key) {
  unsigned int h = 0;
  while (key[0]) {
    h += (unsigned int)*key++;
  }
  return h;
}
ht_node *ht_create_node(const char *key, void *data) {
  ht_node *node = malloc(sizeof(ht_node));
  if (!node) {
    printf("[HashTable] The node with key %s cannot be allocated: %s", key,
           strerror(errno));
    return 0;
  }
  node->key = key;
  node->data = data;
  node->next = 0;
  return node;
}
int ht_insert(ht *p_ht, const char *key, void *data) {
  unsigned int h = ht_hash(key);
  ht_node *node = p_ht->node[h % p_ht->size];
  if (!key) {
    printf("[HashTable] Key is null");
    return 0;
  }

  if (!node) {
    p_ht->node[h % p_ht->size] = ht_create_node(key, data);
  } else {
    if (strcmp(node->key, key) == 0) {
      if (!data) {
        free(node);
        p_ht->node[h % p_ht->size] = 0;
      } else {
        node->data = data;
      }
    } else {
      ht_node *p_new_node = ht_create_node(key, data);
      node->next = p_new_node;
    }
  }
  return 1;
}

void *ht_get(ht *p_ht, const char *key) {
  unsigned int h = ht_hash(key);
  ht_node *node = p_ht->node[h % p_ht->size];

  if (node) {
    if (strcmp(node->key, key) == 0) {
      return node->data;
    } else {
      ht_node *p_curr_node = node;
      while (p_curr_node) {
        if (strcmp(p_curr_node->key, key)) {
          return p_curr_node->data;
        }
        p_curr_node = p_curr_node->next;
      }
      return 0;
    }
  }
  return 0;
}

void free_nodes(ht *p_ht) {
  for (int i = 0; i < p_ht->size; i++) {
    ht_node *p_curr = p_ht->node[i];
    ht_node *next;
    while (p_curr) {
      next = p_curr->next;
      free(p_curr);
      p_curr = next;
    }
  }
}

void ht_clear(ht *p_ht) {
  free_nodes(p_ht);
  free(p_ht);
}
