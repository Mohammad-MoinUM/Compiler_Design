#include "symbol_table.h"
#include <string.h>

/* ========================================
   Hash Function
   ======================================== */

static unsigned int hash_function(const char* name, int table_size) {
    unsigned int hash = 0;
    for (int i = 0; name[i] != '\0'; i++) {
        hash = hash * 31 + name[i];
    }
    return hash % table_size;
}

/* ========================================
   Initialize Symbol Table
   ======================================== */

SymbolTable* init_symbol_table(int size) {
    SymbolTable* table = (SymbolTable*)malloc(sizeof(SymbolTable));
    if (!table) {
        fprintf(stderr, "Memory allocation failed for symbol table\n");
        return NULL;
    }
    
    table->buckets = (Symbol**)calloc(size, sizeof(Symbol*));
    if (!table->buckets) {
        fprintf(stderr, "Memory allocation failed for hash buckets\n");
        free(table);
        return NULL;
    }
    
    table->size = size;
    table->symbol_count = 0;
    return table;
}

/* ========================================
   Insert Symbol into Table
   ======================================== */

bool insert_symbol(SymbolTable* table, const char* name, VarType type,
                   bool is_constant, int line_num) {
    if (!table || !name) return false;
    
    /* Check if symbol already exists */
    if (symbol_exists(table, name)) {
        fprintf(stderr, "Error: Variable '%s' already declared (Line %d)\n", name, line_num);
        return false;
    }
    
    /* Create new symbol */
    Symbol* new_symbol = (Symbol*)malloc(sizeof(Symbol));
    if (!new_symbol) {
        fprintf(stderr, "Memory allocation failed for symbol\n");
        return false;
    }
    
    new_symbol->name = (char*)malloc(strlen(name) + 1);
    if (!new_symbol->name) {
        fprintf(stderr, "Memory allocation failed for symbol name\n");
        free(new_symbol);
        return false;
    }
    
    strcpy(new_symbol->name, name);
    new_symbol->type = type;
    new_symbol->is_constant = is_constant;
    new_symbol->is_initialized = false;
    new_symbol->is_used = false;
    new_symbol->line_declared = line_num;
    new_symbol->line_last_used = -1;
    new_symbol->next = NULL;
    
    /* Initialize value */
    memset(&new_symbol->value, 0, sizeof(new_symbol->value));
    
    /* Insert into hash table */
    unsigned int index = hash_function(name, table->size);
    new_symbol->next = table->buckets[index];
    table->buckets[index] = new_symbol;
    table->symbol_count++;
    
    return true;
}

/* ========================================
   Lookup Symbol
   ======================================== */

Symbol* lookup_symbol(SymbolTable* table, const char* name) {
    if (!table || !name) return NULL;
    
    unsigned int index = hash_function(name, table->size);
    Symbol* current = table->buckets[index];
    
    while (current) {
        if (strcmp(current->name, name) == 0) {
            return current;
        }
        current = current->next;
    }
    
    return NULL;
}

/* ========================================
   Check if Symbol Exists
   ======================================== */

bool symbol_exists(SymbolTable* table, const char* name) {
    return lookup_symbol(table, name) != NULL;
}

/* ========================================
   Set Symbol Value (with constant checking)
   ======================================== */

bool set_symbol_value(SymbolTable* table, const char* name,
                      VarType type, void* value, int line_num) {
    if (!table || !name) return false;
    
    Symbol* symbol = lookup_symbol(table, name);
    if (!symbol) {
        fprintf(stderr, "Error: Variable '%s' not declared (Line %d)\n", name, line_num);
        return false;
    }
    
    /* Check if constant (dhruvo) - cannot reassign */
    if (symbol->is_constant && symbol->is_initialized) {
        fprintf(stderr, "Error: Cannot reassign constant '%s' (Line %d)\n", name, line_num);
        return false;
    }
    
    /* Type checking */
    if (symbol->type != type) {
        fprintf(stderr, "Warning: Type mismatch for '%s' (Line %d)\n", name, line_num);
    }
    
    /* Set value based on type */
    switch (type) {
        case TYPE_INT:
            symbol->value.int_val = *(long*)value;
            break;
        case TYPE_FLOAT:
            symbol->value.float_val = *(double*)value;
            break;
        case TYPE_STRING:
            if (symbol->value.string_val) {
                free(symbol->value.string_val);
            }
            symbol->value.string_val = (char*)malloc(strlen((char*)value) + 1);
            if (symbol->value.string_val) {
                strcpy(symbol->value.string_val, (char*)value);
            }
            break;
        case TYPE_BOOL:
            symbol->value.bool_val = *(bool*)value;
            break;
    }
    
    symbol->is_initialized = true;
    return true;
}

/* ========================================
   Get Symbol Value
   ======================================== */

bool get_symbol_value(SymbolTable* table, const char* name, void* out_value) {
    if (!table || !name) return false;
    
    Symbol* symbol = lookup_symbol(table, name);
    if (!symbol) {
        fprintf(stderr, "Error: Variable '%s' not declared\n", name);
        return false;
    }
    
    if (!symbol->is_initialized) {
        fprintf(stderr, "Error: Variable '%s' used before initialization\n", name);
        return false;
    }
    
    symbol->is_used = true;
    
    /* Copy value based on type */
    switch (symbol->type) {
        case TYPE_INT:
            *(long*)out_value = symbol->value.int_val;
            break;
        case TYPE_FLOAT:
            *(double*)out_value = symbol->value.float_val;
            break;
        case TYPE_STRING:
            *(char**)out_value = symbol->value.string_val;
            break;
        case TYPE_BOOL:
            *(bool*)out_value = symbol->value.bool_val;
            break;
    }
    
    return true;
}

/* ========================================
   Check if Symbol is Constant
   ======================================== */

bool is_symbol_constant(SymbolTable* table, const char* name) {
    Symbol* symbol = lookup_symbol(table, name);
    return symbol && symbol->is_constant;
}

/* ========================================
   Print Symbol Table (for debugging)
   ======================================== */

void print_symbol_table(FILE* file, SymbolTable* table) {
    if (!table || !file) return;
    
    fprintf(file, "\n========================================\n");
    fprintf(file, "         SYMBOL TABLE CONTENTS\n");
    fprintf(file, "========================================\n");
    fprintf(file, "Total Symbols: %d\n\n", table->symbol_count);
    
    fprintf(file, "%-20s | %-10s | %-8s | %-12s | Line\n", 
            "Name", "Type", "Const?", "Initialized?");
    fprintf(file, "---------------------------------------------\n");
    
    for (int i = 0; i < table->size; i++) {
        Symbol* current = table->buckets[i];
        while (current) {
            const char* type_str = "";
            switch (current->type) {
                case TYPE_INT: type_str = "int"; break;
                case TYPE_FLOAT: type_str = "float"; break;
                case TYPE_STRING: type_str = "string"; break;
                case TYPE_BOOL: type_str = "bool"; break;
            }
            
            fprintf(file, "%-20s | %-10s | %-8s | %-12s | %d\n",
                    current->name,
                    type_str,
                    current->is_constant ? "yes" : "no",
                    current->is_initialized ? "yes" : "no",
                    current->line_declared);
            
            current = current->next;
        }
    }
    
    fprintf(file, "========================================\n\n");
}

/* ========================================
   Free Symbol Table
   ======================================== */

void free_symbol_table(SymbolTable* table) {
    if (!table) return;
    
    for (int i = 0; i < table->size; i++) {
        Symbol* current = table->buckets[i];
        while (current) {
            Symbol* temp = current;
            current = current->next;
            
            if (temp->name) free(temp->name);
            if (temp->type == TYPE_STRING && temp->value.string_val) {
                free(temp->value.string_val);
            }
            free(temp);
        }
    }
    
    if (table->buckets) free(table->buckets);
    free(table);
}
