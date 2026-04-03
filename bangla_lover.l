%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symbol_table.h"
#include "bangla_lover.tab.h"

/*
  Bangla Lover (BLPL) - Lexical Analyzer (Flex)
  ------------------------------------------------
  Integrated with Bison parser. Returns tokens instead of printing.
  Handles keywords, identifiers, literals, operators, and delimiters.
*/
%}

%option noyywrap
%option yylineno

DIGIT           [0-9]
LETTER          [a-zA-Z]
IDENTIFIER      ({LETTER}|_)({LETTER}|{DIGIT}|_)*
INTEGER         {DIGIT}+
FLOAT           ({DIGIT}+\.{DIGIT}+)
WHITESPACE      [ \t\r]+
NEWLINE         \n

%%

"//".*                  { /* Single-line comment */ }

"/*"                    {
                            int c, prev = 0;
                            while ((c = input()) != EOF) {
                                if (c == '\n') { yylineno++; }
                                if (prev == '*' && c == '/') break;
                                prev = c;
                            }
                        }

"dhoro"                 { return KW_DHORO; }
"dhruvo"                { return KW_DHRUVO; }
"jodi"                  { return KW_JODI; }
"nahole"                { return KW_NAHOLE; }
"jotokkhon"             { return KW_JOTOKKHON; }
"barbar"                { return KW_BARBAR; }
"dekhao"                { return KW_DEKHAO; }
"ne"                    { return KW_NE; }

"sin"                   { return KW_SIN; }
"cos"                   { return KW_COS; }
"tan"                   { return KW_TAN; }
"sec"                   { return KW_SEC; }
"borgo"                 { return KW_BORGO; }
"boro"                  { return KW_BORO; }
"soto"                  { return KW_SOTO; }

"true"                  { return BOOL_TRUE; }
"false"                 { return BOOL_FALSE; }

\"([^\\\n\"]|\\.)*\"    { 
                            yylval.str_val = (char*)malloc(yyleng + 1);
                            strcpy(yylval.str_val, yytext);
                            return STRING_LITERAL;
                        }

[0-9]+\.[0-9]+          { 
                            yylval.num_val = atof(yytext);
                            return FLOAT_LITERAL;
                        }

[0-9]+                  { 
                            yylval.num_val = atof(yytext);
                            return INT_LITERAL;
                        }

[a-zA-Z_][a-zA-Z0-9_]* { 
                            yylval.str_val = (char*)malloc(yyleng + 1);
                            strcpy(yylval.str_val, yytext);
                            return IDENTIFIER;
                        }

"=="                    { return OP_EQ; }
"!="                    { return OP_NEQ; }
"<="                    { return OP_LTE; }
">="                    { return OP_GTE; }
"<"                     { return OP_LT; }
">"                     { return OP_GT; }
"="                     { return OP_ASSIGN; }

"&&"                    { return OP_AND; }
"||"                    { return OP_OR; }
"!"                     { return OP_NOT; }

"+"                     { return OP_PLUS_SYM; }
"-"                     { return OP_MINUS_SYM; }
"*"                     { return OP_STAR_SYM; }
"/"                     { return OP_SLASH_SYM; }
"%"                     { return OP_MOD; }

"("                     { return LPAREN; }
")"                     { return RPAREN; }
"{"                     { return LBRACE; }
"}"                     { return RBRACE; }
";"                     { return SEMICOLON; }
","                     { return COMMA; }

[ \t\r]+                { /* Whitespace */ }
\n                      { /* Flex tracks yylineno automatically */ }

.                       {
                            fprintf(stderr, "Lexical Error: Unrecognized character '%c' at line %d\n",
                                    yytext[0], yylineno);
                        }

%%
