#ifndef SYMBOL_TABLE_H
#define SYMBOL_TABLE_H

#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>

/* ========================================
   Variable Type Enumeration
   ======================================== */

typedef enum {
    TYPE_INT,
    TYPE_FLOAT,
    TYPE_STRING,
    TYPE_BOOL
} VarType;

/* ========================================
   Symbol Structure (for symbol table entry)
   ======================================== */

typedef struct Symbol {
    char* name;              /* Variable name */
    VarType type;            /* Variable type (int, float, string, bool) */
    bool is_constant;        /* Flag: true if dhruvo (constant), false if dhoro (variable) */
    bool is_initialized;     /* Has value been assigned? */
    bool is_used;            /* Has variable been used in expression? */
    
    /* Value storage */
    union {
        long int_val;
        double float_val;
        char* string_val;
        bool bool_val;
    } value;
    
    int line_declared;       /* Line where variable was declared */
    int line_last_used;      /* Line where variable was last used */
    
    struct Symbol* next;     /* For collision handling in hash table */
} Symbol;

/* ========================================
   Symbol Table Structure
   ======================================== */

typedef struct {
    Symbol** buckets;        /* Hash table buckets (array of linked lists) */
    int size;                /* Number of buckets */
    int symbol_count;        /* Total symbols stored */
} SymbolTable;

/* ========================================
   Function Declarations
   ======================================== */

/* Initialize symbol table with given size */
SymbolTable* init_symbol_table(int size);

/* Insert a new symbol (return false if already exists) */
bool insert_symbol(SymbolTable* table, const char* name, VarType type, 
                   bool is_constant, int line_num);

/* Lookup symbol by name (return NULL if not found) */
Symbol* lookup_symbol(SymbolTable* table, const char* name);

/* Set value for a symbol (return false if constant or not found) */
bool set_symbol_value(SymbolTable* table, const char* name, 
                      VarType type, void* value, int line_num);

/* Get value from symbol (return false if not initialized) */
bool get_symbol_value(SymbolTable* table, const char* name, void* out_value);

/* Check if symbol is constant */
bool is_symbol_constant(SymbolTable* table, const char* name);

/* Check if symbol exists */
bool symbol_exists(SymbolTable* table, const char* name);

/* Print entire symbol table to file */
void print_symbol_table(FILE* file, SymbolTable* table);

/* Free symbol table memory */
void free_symbol_table(SymbolTable* table);

#endif /* SYMBOL_TABLE_H */
