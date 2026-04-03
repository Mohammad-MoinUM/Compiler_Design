
/* A Bison parser, made by GNU Bison 2.4.1.  */

/* Skeleton interface for Bison's Yacc-like parsers in C
   
      Copyright (C) 1984, 1989, 1990, 2000, 2001, 2002, 2003, 2004, 2005, 2006
   Free Software Foundation, Inc.
   
   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.
   
   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.
   
   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.
   
   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */


/* Tokens.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
   /* Put the tokens into the symbol table, so that GDB and other debuggers
      know about them.  */
   enum yytokentype {
     KW_DHORO = 258,
     KW_DHRUVO = 259,
     KW_JODI = 260,
     KW_NAHOLE = 261,
     KW_JOTOKKHON = 262,
     KW_BARBAR = 263,
     KW_DEKHAO = 264,
     KW_NE = 265,
     KW_SIN = 266,
     KW_COS = 267,
     KW_TAN = 268,
     KW_SEC = 269,
     KW_BORO = 270,
     KW_SOTO = 271,
     OP_EQ = 272,
     OP_NEQ = 273,
     OP_LTE = 274,
     OP_GTE = 275,
     OP_LT = 276,
     OP_GT = 277,
     OP_ASSIGN = 278,
     OP_AND = 279,
     OP_OR = 280,
     OP_NOT = 281,
     OP_PLUS_SYM = 282,
     OP_MINUS_SYM = 283,
     OP_STAR_SYM = 284,
     OP_SLASH_SYM = 285,
     OP_MOD = 286,
     LPAREN = 287,
     RPAREN = 288,
     LBRACE = 289,
     RBRACE = 290,
     SEMICOLON = 291,
     COMMA = 292,
     BOOL_TRUE = 293,
     BOOL_FALSE = 294,
     IDENTIFIER = 295,
     STRING_LITERAL = 296,
     INT_LITERAL = 297,
     FLOAT_LITERAL = 298,
     UMINUS = 299
   };
#endif



#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef union YYSTYPE
{

/* Line 1676 of yacc.c  */
#line 45 "bangla_lover.y"

    char* str_val;
    double num_val;
    struct {
        char expr_str[500];
        VarType type;
        double value;
    } expr_val;



/* Line 1676 of yacc.c  */
#line 108 "bangla_lover.tab.h"
} YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
#endif

extern YYSTYPE yylval;


