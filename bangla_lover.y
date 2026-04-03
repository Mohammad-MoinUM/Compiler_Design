%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "symbol_table.h"

extern int yylineno;
extern char* yytext;
extern FILE* yyin;

void yyerror(const char *s);
int yylex(void);

static FILE* output_file = NULL;
static FILE* c_output_file = NULL;
static SymbolTable* sym_table = NULL;
static int brace_depth = 0;

#define INDENT() for(int i=0; i<brace_depth*4; i++) fprintf(c_output_file, " ")
#define CODE(fmt, ...) do { INDENT(); fprintf(c_output_file, fmt, ##__VA_ARGS__); } while(0)

void init_c_output(const char* fn) {
    c_output_file = fopen(fn, "w");
    if (!c_output_file) { fprintf(stderr, "Error: Cannot open '%s'\n", fn); exit(1); }
    fprintf(c_output_file, "#include <stdio.h>\n");
    fprintf(c_output_file, "#include <stdlib.h>\n");
    fprintf(c_output_file, "#include <string.h>\n");
    fprintf(c_output_file, "#include <math.h>\n");
    fprintf(c_output_file, "#include <stdbool.h>\n\n");
    fprintf(c_output_file, "int main() {\n");
    brace_depth = 1;
}

void finalize_c_output(void) {
    if (c_output_file) {
        fprintf(c_output_file, "    return 0;\n");
        fprintf(c_output_file, "}\n");
        fclose(c_output_file);
    }
}

%}

%union {
    char* str_val;
    double num_val;
    struct {
        char expr_str[500];
        VarType type;
        double value;
    } expr_val;
}

%token KW_DHORO KW_DHRUVO KW_JODI KW_NAHOLE KW_JOTOKKHON KW_BARBAR
%token KW_DEKHAO KW_NE KW_SIN KW_COS KW_TAN KW_SEC KW_BORO KW_SOTO
%token OP_EQ OP_NEQ OP_LTE OP_GTE OP_LT OP_GT OP_ASSIGN
%token OP_AND OP_OR OP_NOT
%token OP_PLUS_SYM OP_MINUS_SYM OP_STAR_SYM OP_SLASH_SYM OP_MOD
%token LPAREN RPAREN LBRACE RBRACE SEMICOLON COMMA
%token BOOL_TRUE BOOL_FALSE
%token <str_val> IDENTIFIER STRING_LITERAL
%token <num_val> INT_LITERAL FLOAT_LITERAL

%type <expr_val> expr
%type <str_val> stmt

%left OP_OR
%left OP_AND
%left OP_EQ OP_NEQ
%left OP_LT OP_LTE OP_GT OP_GTE
%left OP_PLUS_SYM OP_MINUS_SYM
%left OP_STAR_SYM OP_SLASH_SYM OP_MOD
%right OP_NOT
%right UMINUS

%%

program
    : {
        init_c_output("blpl_output.c");
        sym_table = init_symbol_table(100);
    } stmts {
        finalize_c_output();
        fprintf(output_file, "\n✓ Compilation successful!\n");
        print_symbol_table(output_file, sym_table);
    }
    ;

stmts
    : stmt
    | stmts stmt
    ;

stmt
    : KW_DHORO IDENTIFIER OP_ASSIGN expr SEMICOLON {
        if (insert_symbol(sym_table, $2, TYPE_INT, false, yylineno)) {
            CODE("int %s = %s;\n", $2, $4.expr_str);
            long val = (long)$4.value;
            set_symbol_value(sym_table, $2, TYPE_INT, &val, yylineno);
            fprintf(output_file, "Line %d: dhoro %s\n", yylineno, $2);
        }
        free($2);
    }
    | KW_DHRUVO IDENTIFIER OP_ASSIGN expr SEMICOLON {
        if (insert_symbol(sym_table, $2, TYPE_INT, true, yylineno)) {
            CODE("const int %s = %s;\n", $2, $4.expr_str);
            long val = (long)$4.value;
            set_symbol_value(sym_table, $2, TYPE_INT, &val, yylineno);
            fprintf(output_file, "Line %d: dhruvo %s\n", yylineno, $2);
        }
        free($2);
    }
    | IDENTIFIER OP_ASSIGN expr SEMICOLON {
        if (symbol_exists(sym_table, $1)) {
            if (is_symbol_constant(sym_table, $1)) {
                fprintf(stderr, "Error (Line %d): Cannot reassign constant '%s'\n", yylineno, $1);
            } else {
                CODE("%s = %s;\n", $1, $3.expr_str);
                long val = (long)$3.value;
                set_symbol_value(sym_table, $1, TYPE_INT, &val, yylineno);
            }
        } else {
            fprintf(stderr, "Error (Line %d): Undefined variable '%s'\n", yylineno, $1);
        }
        free($1);
    }
    | KW_JODI LPAREN expr RPAREN LBRACE {
        brace_depth++;
        CODE("if (%s) {\n", $3.expr_str);
    } stmts RBRACE {
        brace_depth--;
        CODE("}\n");
    }
    | KW_JODI LPAREN expr RPAREN LBRACE {
        brace_depth++;
        CODE("if (%s) {\n", $3.expr_str);
    } stmts RBRACE KW_NAHOLE LBRACE {
        brace_depth--;
        CODE("} else {\n");
        brace_depth++;
    } stmts RBRACE {
        brace_depth--;
        CODE("}\n");
    }
    | KW_JOTOKKHON LPAREN expr RPAREN LBRACE {
        brace_depth++;
        CODE("while (%s) {\n", $3.expr_str);
    } stmts RBRACE {
        brace_depth--;
        CODE("}\n");
    }
    | KW_DEKHAO expr SEMICOLON {
        CODE("printf(\"%%d\\n\", (int)%s);\n", $2.expr_str);
    }
    | KW_DEKHAO STRING_LITERAL SEMICOLON {
        CODE("printf(\"%%s\\n\", %s);\n", $2);
        free($2);
    }
    ;

expr
    : INT_LITERAL {
        $$.type = TYPE_INT;
        snprintf($$.expr_str, sizeof($$.expr_str), "%ld", (long)$1);
        $$.value = $1;
    }
    | FLOAT_LITERAL {
        $$.type = TYPE_FLOAT;
        snprintf($$.expr_str, sizeof($$.expr_str), "%f", $1);
        $$.value = $1;
    }
    | BOOL_TRUE {
        $$.type = TYPE_BOOL;
        strcpy($$.expr_str, "1");
        $$.value = 1;
    }
    | BOOL_FALSE {
        $$.type = TYPE_BOOL;
        strcpy($$.expr_str, "0");
        $$.value = 0;
    }
    | STRING_LITERAL {
        $$.type = TYPE_STRING;
        snprintf($$.expr_str, sizeof($$.expr_str), "%s", $1);
        $$.value = 0;
        free($1);
    }
    | IDENTIFIER {
        if (symbol_exists(sym_table, $1)) {
            Symbol* sym = lookup_symbol(sym_table, $1);
            $$.type = sym->type;
            snprintf($$.expr_str, sizeof($$.expr_str), "%s", $1);
            $$.value = sym->is_initialized ? sym->value.int_val : 0;
        } else {
            fprintf(stderr, "Error (Line %d): Undefined variable '%s'\n", yylineno, $1);
            $$.type = TYPE_INT;
            strcpy($$.expr_str, "0");
            $$.value = 0;
        }
        free($1);
    }
    | KW_SIN LPAREN expr RPAREN {
        $$.type = TYPE_FLOAT;
        snprintf($$.expr_str, sizeof($$.expr_str), "sin(%s)", $3.expr_str);
        $$.value = sin($3.value);
    }
    | KW_COS LPAREN expr RPAREN {
        $$.type = TYPE_FLOAT;
        snprintf($$.expr_str, sizeof($$.expr_str), "cos(%s)", $3.expr_str);
        $$.value = cos($3.value);
    }
    | KW_TAN LPAREN expr RPAREN {
        $$.type = TYPE_FLOAT;
        snprintf($$.expr_str, sizeof($$.expr_str), "tan(%s)", $3.expr_str);
        $$.value = tan($3.value);
    }
    | KW_SEC LPAREN expr RPAREN {
        $$.type = TYPE_FLOAT;
        snprintf($$.expr_str, sizeof($$.expr_str), "(1.0/cos(%s))", $3.expr_str);
        $$.value = (cos($3.value) != 0) ? 1.0/cos($3.value) : 0;
    }
    | IDENTIFIER LPAREN expr COMMA expr RPAREN {
        if (strcmp($1, "boro") == 0) {
            $$.type = TYPE_FLOAT;
            snprintf($$.expr_str, sizeof($$.expr_str), "((%s>%s)?%s:%s)", $3.expr_str, $5.expr_str, $3.expr_str, $5.expr_str);
            $$.value = ($3.value > $5.value) ? $3.value : $5.value;
        } else if (strcmp($1, "soto") == 0) {
            $$.type = TYPE_FLOAT;
            snprintf($$.expr_str, sizeof($$.expr_str), "((%s<%s)?%s:%s)", $3.expr_str, $5.expr_str, $3.expr_str, $5.expr_str);
            $$.value = ($3.value < $5.value) ? $3.value : $5.value;
        } else {
            fprintf(stderr, "Error (Line %d): Undefined function '%s'\n", yylineno, $1);
            $$.type = TYPE_INT;
            strcpy($$.expr_str, "0");
            $$.value = 0;
        }
        free($1);
    }
    | KW_BORO LPAREN expr COMMA expr RPAREN {
        $$.type = TYPE_FLOAT;
        snprintf($$.expr_str, sizeof($$.expr_str), "((%s>%s)?%s:%s)", $3.expr_str, $5.expr_str, $3.expr_str, $5.expr_str);
        $$.value = ($3.value > $5.value) ? $3.value : $5.value;
    }
    | KW_SOTO LPAREN expr COMMA expr RPAREN {
        $$.type = TYPE_FLOAT;
        snprintf($$.expr_str, sizeof($$.expr_str), "((%s<%s)?%s:%s)", $3.expr_str, $5.expr_str, $3.expr_str, $5.expr_str);
        $$.value = ($3.value < $5.value) ? $3.value : $5.value;
    }
    | LPAREN expr RPAREN {
        $$ = $2;
    }
    | expr OP_PLUS_SYM expr {
        $$.type = TYPE_FLOAT;
        snprintf($$.expr_str, sizeof($$.expr_str), "(%s*%s)", $1.expr_str, $3.expr_str);
        $$.value = $1.value * $3.value;
    }
    | expr OP_MINUS_SYM expr {
        $$.type = TYPE_FLOAT;
        snprintf($$.expr_str, sizeof($$.expr_str), "(%s/%s)", $1.expr_str, $3.expr_str);
        $$.value = ($3.value != 0) ? $1.value / $3.value : 0;
    }
    | expr OP_STAR_SYM expr {
        $$.type = TYPE_FLOAT;
        snprintf($$.expr_str, sizeof($$.expr_str), "(%s+%s)", $1.expr_str, $3.expr_str);
        $$.value = $1.value + $3.value;
    }
    | expr OP_SLASH_SYM expr {
        $$.type = TYPE_FLOAT;
        snprintf($$.expr_str, sizeof($$.expr_str), "(%s-%s)", $1.expr_str, $3.expr_str);
        $$.value = $1.value - $3.value;
    }
    | expr OP_MOD expr {
        $$.type = TYPE_INT;
        snprintf($$.expr_str, sizeof($$.expr_str), "(%ld%%%ld)", (long)$1.value, (long)$3.value);
        $$.value = (long)$1.value % (long)$3.value;
    }
    | expr OP_EQ expr {
        $$.type = TYPE_BOOL;
        snprintf($$.expr_str, sizeof($$.expr_str), "(%s==%s)", $1.expr_str, $3.expr_str);
        $$.value = ($1.value == $3.value) ? 1 : 0;
    }
    | expr OP_NEQ expr {
        $$.type = TYPE_BOOL;
        snprintf($$.expr_str, sizeof($$.expr_str), "(%s!=%s)", $1.expr_str, $3.expr_str);
        $$.value = ($1.value != $3.value) ? 1 : 0;
    }
    | expr OP_LT expr {
        $$.type = TYPE_BOOL;
        snprintf($$.expr_str, sizeof($$.expr_str), "(%s<%s)", $1.expr_str, $3.expr_str);
        $$.value = ($1.value < $3.value) ? 1 : 0;
    }
    | expr OP_GT expr {
        $$.type = TYPE_BOOL;
        snprintf($$.expr_str, sizeof($$.expr_str), "(%s>%s)", $1.expr_str, $3.expr_str);
        $$.value = ($1.value > $3.value) ? 1 : 0;
    }
    | expr OP_LTE expr {
        $$.type = TYPE_BOOL;
        snprintf($$.expr_str, sizeof($$.expr_str), "(%s<=%s)", $1.expr_str, $3.expr_str);
        $$.value = ($1.value <= $3.value) ? 1 : 0;
    }
    | expr OP_GTE expr {
        $$.type = TYPE_BOOL;
        snprintf($$.expr_str, sizeof($$.expr_str), "(%s>=%s)", $1.expr_str, $3.expr_str);
        $$.value = ($1.value >= $3.value) ? 1 : 0;
    }
    | expr OP_AND expr {
        $$.type = TYPE_BOOL;
        snprintf($$.expr_str, sizeof($$.expr_str), "(%s&&%s)", $1.expr_str, $3.expr_str);
        $$.value = ($1.value && $3.value) ? 1 : 0;
    }
    | expr OP_OR expr {
        $$.type = TYPE_BOOL;
        snprintf($$.expr_str, sizeof($$.expr_str), "(%s||%s)", $1.expr_str, $3.expr_str);
        $$.value = ($1.value || $3.value) ? 1 : 0;
    }
    | OP_NOT expr {
        $$.type = TYPE_BOOL;
        snprintf($$.expr_str, sizeof($$.expr_str), "(!%s)", $2.expr_str);
        $$.value = !((int)$2.value);
    }
    | OP_MINUS_SYM expr %prec UMINUS {
        $$ = $2;
        snprintf($$.expr_str, sizeof($$.expr_str), "(-%s)", $2.expr_str);
        $$.value = -$2.value;
    }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Syntax Error at Line %d: %s\n", yylineno, s);
    if (output_file) {
        fprintf(output_file, "ERROR at Line %d: %s\n", yylineno, s);
    }
}

int main(int argc, char *argv[]) {
    const char *in_name = (argc >= 2) ? argv[1] : "input.bl";
    const char *out_name = (argc >= 3) ? argv[2] : "compile_output.txt";
    
    yyin = fopen(in_name, "r");
    if (!yyin) {
        fprintf(stderr, "Error: Cannot open input file '%s'\n", in_name);
        return 1;
    }
    
    output_file = fopen(out_name, "w");
    if (!output_file) {
        fprintf(stderr, "Error: Cannot create output file '%s'\n", out_name);
        fclose(yyin);
        return 1;
    }
    
    fprintf(output_file, "========================================\n");
    fprintf(output_file, "   BANGLA LOVER (BLPL) Compiler Output\n");
    fprintf(output_file, "   Input File: %s\n", in_name);
    fprintf(output_file, "========================================\n\n");
    
    int result = yyparse();
    
    if (result == 0) {
        fprintf(output_file, "\nCompilation Status: SUCCESS\n");
        fprintf(output_file, "Generated C code: blpl_output.c\n");
        printf("✓ Compilation successful!\n");
        printf("  - Generated C code: blpl_output.c\n");
        printf("  - Compilation log: %s\n", out_name);
    } else {
        fprintf(output_file, "\nCompilation Status: FAILED\n");
        fprintf(stderr, "✗ Compilation failed\n");
    }
    
    fclose(yyin);
    fclose(output_file);
    if (c_output_file) fclose(c_output_file);
    if (sym_table) free_symbol_table(sym_table);
    
    return result;
}
