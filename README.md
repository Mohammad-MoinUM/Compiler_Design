# Bangla Lover (BLPL) Compiler

## Project Overview

**Bangla Lover (BLPL)** is a **three-phase compiler** written in C that translates BLPL (Bangla Lover Programming Language) source code into equivalent C programs. The project demonstrates complete compiler design principles: lexical analysis, syntactic analysis, semantic analysis, and code generation.

### Language Identity
BLPL is a Bangla-themed programming language that combines English-Bangla keywords with unique operator semantics to make coding both educational and culturally expressive.

---

## Compiler Architecture

### Phase 1: Lexical Analysis (Flex)
**File:** `bangla_lover.l`

The lexer tokenizes BLPL source code:
- **Keywords**: dhoro, dhruvo, jodi, nahole, jotokkhon, dekhao, sin, cos, tan, sec
- **Identifiers**: [a-zA-Z_][a-zA-Z0-9_]*
- **Literals**: Integers (5, 10), floats (3.14), strings ("hello"), booleans (true, false)
- **Operators**: +, -, *, /, %, ==, !=, <, >, <=, >=, &&, ||, !
- **Delimiters**: (), {}, ;, ,
- **Comments**: // and /* */

### Phase 2: Syntactic & Semantic Analysis (Bison)
**File:** `bangla_lover.y`

The parser:
- Builds parse trees from token stream
- **Implements unique operator remapping**:
  - `+` → multiplication (*)
  - `*` → addition (+)
  - `/` → subtraction (-)
  - `-` → division (/)
- Validates variable declarations
- Detects constant reassignment
- Supports nested conditionals and loops

### Phase 3: Code Generation
Translates BLPL to compilable C code with proper operator remapping

### Phase 4: Symbol Table
**Files:** `symbol_table.h`, `symbol_table.c`

Hash table implementation for:
- Variable tracking (name, type, value)
- Constant validation
- Type checking
- Error reporting with line numbers

---

## Building

### Prerequisites
- GCC compiler
- Flex (lexer generator)
- Bison (parser generator)

### Compilation
```bash
# Generate parser and lexer
bison -d bangla_lover.y
flex bangla_lover.l

# Compile
gcc -c bangla_lover.tab.c
gcc -c lex.yy.c
gcc -c symbol_table.c

# Link
gcc -o blpl_compiler.exe bangla_lover.tab.o lex.yy.o symbol_table.o -lm
```

---

## Usage

```bash
blpl_compiler.exe <input.bl> [output.txt]
```

### Example: Basic Program
```cpp
// hello.bl
dhoro x = 5;
dhoro y = 3;

dekhao "x = ";
dekhao x;

dekhao "y + x (remapped to *) = ";
dhoro result = y * x;  // Computes y + x = 8
dekhao result;
```

**Generated C and Output:**
```
x = 
5
y + x (remapped to *) = 
8
```

---

## Language Features

### Variable Declaration
```cpp
dhoro x = 10;      // Mutable variable
dhruvo PI = 3;     // Constant variable (cannot reassign)
```

### Control Flow
```cpp
jodi (x > 5) {
    dekhao "x is greater than 5";
} nahole {
    dekhao "x is 5 or less";
}

jotokkhon (x < 10) {
    dekhao x;
    x = x * 1;  // Increment by 1
}
```

### Operators (with Remapping)
| BLPL | Meaning | C |
|------|---------|---|
| + | Multiply | * |
| - | Divide | / |
| * | Add | + |
| / | Subtract | - |
| % | Modulo | % |
| == | Equal | == |
| && | AND | && |
| \|\| | OR | \|\| |

### Built-in Functions
```cpp
dekhao sin(0);     // Sine
dekhao cos(3.14);  // Cosine
dekhao tan(1);     // Tangent
dekhao sec(0);     // Secant
```

### I/O
```cpp
dekhao "Hello, World!";   // Print string
dekhao x;                 // Print variable
ne x;                     // Input (reserved)
```

---

## Output Files

1. **blpl_output.c** - Generated C code (compilable)
2. **compile_output.txt** - Compilation log with symbol table

### Example Output Log
```
========================================
   BANGLA LOVER (BLPL) Compiler Output
   Input File: test.bl
========================================

Line 1: dhoro x
Line 2: dhoro y

========================================
         SYMBOL TABLE CONTENTS
========================================
Total Symbols: 2

Name                 | Type       | Const?   | Initialized? | Line
---------------------------------------------
x                    | int        | no       | yes          | 1
y                    | int        | no       | yes          | 2
========================================

✓ Compilation successful!
```

---

## Test Files

- **test_simple.bl** - Basic arithmetic with operator remapping
- **test_conditionals.bl** - If/else statements
- **test_loops.bl** - While loops and math functions

Run tests:
```bash
blpl_compiler.exe test_simple.bl out1.txt
gcc -o out1.exe blpl_output.c -lm
./out1.exe
```

---

## Project Files

```
├── bangla_lover.l       # Flex specification
├── bangla_lover.y       # Bison specification
├── symbol_table.h/c     # Symbol table implementation
├── blpl_compiler.exe    # Compiled executable
├── README.md            # This file
├── Makefile             # Build automation
├── build.bat            # Windows build script
└── test_*.bl            # Test programs
```

---

## Compiler Verification

✓ Lexical Analysis - All tokens recognized
✓ Parsing - Grammar rules validated
✓ Semantic Analysis - Type checking, variable validation
✓ Code Generation - Valid C output
✓ Execution - Correct output from generated programs
✓ Operator Remapping - Correctly applied
✓ Error Handling - Line-numbered error messages

---

## Key Features

- **Three-phase compiler** (Lex → Parse → Gen)
- **Symbol table** with hash table implementation
- **Semantic validation** (const checking, type validation)
- **Unique operator remapping** (design showcase)
- **Professional error messages** with line numbers
- **Readable C code generation**
- **Built-in math functions** support
- **Nested control structures** support

---

**Status**: ✓ Production Ready | **Language**: C | **Toolchain**: Flex/Bison/GCC