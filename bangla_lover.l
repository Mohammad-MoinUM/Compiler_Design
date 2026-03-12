%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/*
  Bangla Lover (BLPL) - Lexical Analyzer (Flex)
  ------------------------------------------------
  Output style: TOKEN_TYPE : lexeme (Line: x, Col: y)

  This is the tokenization/demo lexer (prints tokens). When you move to Bison,
  replace print_token(...) actions with: return TOKEN; and set yylval as needed.
*/

static int line_number = 1;
static int column_number = 1;

static void update_position(const char *text) {
    for (int i = 0; i < yyleng; i++) {
        if (text[i] == '\n') {
            line_number++;
            column_number = 1;
        } else {
            column_number++;
        }
    }
}

#define print_token(type, value) \
    fprintf(yyout, "%-22s : %-20s (Line: %d, Col: %d)\n", \
            type, value, line_number, column_number - yyleng)
%}

%option noyywrap

DIGIT           [0-9]
LETTER          [a-zA-Z]
IDENTIFIER      ({LETTER}|_)({LETTER}|{DIGIT}|_)*
INTEGER         {DIGIT}+
FLOAT           ({DIGIT}+\.{DIGIT}+)
WHITESPACE      [ \t\r]+
NEWLINE         \n

%%

"//".*                  { update_position(yytext); }

"/*"                    {
                            int c, prev = 0;
                            while ((c = input()) != EOF) {
                                if (c == '\n') { line_number++; column_number = 1; }
                                else { column_number++; }
                                if (prev == '*' && c == '/') break;
                                prev = c;
                            }
                        }

"dhoro"                 { update_position(yytext); print_token("KW_DHORO", yytext); }
"dhruvo"                { update_position(yytext); print_token("KW_DHRUVO", yytext); }
"jodi"                  { update_position(yytext); print_token("KW_JODI", yytext); }
"nahole"                { update_position(yytext); print_token("KW_NAHOLE", yytext); }
"jotokkhon"             { update_position(yytext); print_token("KW_JOTOKKHON", yytext); }
"barbar"                { update_position(yytext); print_token("KW_BARBAR", yytext); }
"dekhao"                { update_position(yytext); print_token("KW_DEKHAO", yytext); }
"ne"                    { update_position(yytext); print_token("KW_NE", yytext); }

"sin"                   { update_position(yytext); print_token("KW_SIN", yytext); }
"cos"                   { update_position(yytext); print_token("KW_COS", yytext); }
"tan"                   { update_position(yytext); print_token("KW_TAN", yytext); }
"sec"                   { update_position(yytext); print_token("KW_SEC", yytext); }

"true"                  { update_position(yytext); print_token("BOOL_TRUE", yytext); }
"false"                 { update_position(yytext); print_token("BOOL_FALSE", yytext); }

\"([^\\\n\"]|\\.)*\"    { update_position(yytext); print_token("STRING_LITERAL", yytext); }

{FLOAT}                 { update_position(yytext); print_token("FLOAT_LITERAL", yytext); }
{INTEGER}               { update_position(yytext); print_token("INT_LITERAL", yytext); }

{IDENTIFIER}            { update_position(yytext); print_token("IDENTIFIER", yytext); }

"=="                    { update_position(yytext); print_token("OP_EQ", yytext); }
"!="                    { update_position(yytext); print_token("OP_NEQ", yytext); }
"<="                    { update_position(yytext); print_token("OP_LTE", yytext); }
">="                    { update_position(yytext); print_token("OP_GTE", yytext); }
"<"                     { update_position(yytext); print_token("OP_LT", yytext); }
">"                     { update_position(yytext); print_token("OP_GT", yytext); }
"="                     { update_position(yytext); print_token("OP_ASSIGN", yytext); }

"&&"                    { update_position(yytext); print_token("OP_AND", yytext); }
"||"                    { update_position(yytext); print_token("OP_OR", yytext); }
"!"                     { update_position(yytext); print_token("OP_NOT", yytext); }

"+"                     { update_position(yytext); print_token("OP_PLUS_SYM", yytext); }
"-"                     { update_position(yytext); print_token("OP_MINUS_SYM", yytext); }
"*"                     { update_position(yytext); print_token("OP_STAR_SYM", yytext); }
"/"                     { update_position(yytext); print_token("OP_SLASH_SYM", yytext); }
"%"                     { update_position(yytext); print_token("OP_MOD", yytext); }

"("                     { update_position(yytext); print_token("LPAREN", yytext); }
")"                     { update_position(yytext); print_token("RPAREN", yytext); }
"{"                     { update_position(yytext); print_token("LBRACE", yytext); }
"}"                     { update_position(yytext); print_token("RBRACE", yytext); }
";"                     { update_position(yytext); print_token("SEMICOLON", yytext); }
","                     { update_position(yytext); print_token("COMMA", yytext); }

{WHITESPACE}            { update_position(yytext); }
{NEWLINE}               { line_number++; column_number = 1; }

.                       {
                            fprintf(yyout,
                                    "ERROR: Unrecognized character '%s' at line %d, column %d\n",
                                    yytext, line_number, column_number);
                            update_position(yytext);
                        }

%%

int main(int argc, char *argv[]) {
    const char *in_name = (argc >= 2) ? argv[1] : "test.bl";
    const char *out_name = (argc >= 3) ? argv[2] : "lexer_output.txt";

    FILE *input_file = fopen(in_name, "r");
    if (!input_file) {
        fprintf(stderr, "Error: Cannot open input file '%s'\n", in_name);
        return 1;
    }

    FILE *output_file = fopen(out_name, "w");
    if (!output_file) {
        fprintf(stderr, "Error: Cannot create output file '%s'\n", out_name);
        fclose(input_file);
        return 1;
    }

    yyin = input_file;
    yyout = output_file;

    fprintf(output_file, "========================================\n");
    fprintf(output_file, "   Bangla Lover (BLPL) Lexical Output\n");
    fprintf(output_file, "   Source File: %s\n", in_name);
    fprintf(output_file, "========================================\n\n");

    yylex();

    fprintf(output_file, "\n========================================\n");
    fprintf(output_file, "       Lexical Analysis Complete\n");
    fprintf(output_file, "========================================\n");

    fclose(input_file);
    fclose(output_file);

    printf("Lexing done. Output written to %s\n", out_name);
    return 0;
}
