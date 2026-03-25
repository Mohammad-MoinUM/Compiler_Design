@echo off
setlocal enabledelayedexpansion

echo ========================================
echo   Building Bangla Lover (BLPL) Compiler
echo ========================================
echo.

cd /d "e:\Semesters\3-2\3-2 projects\compiler"

echo Step 1: Generating Bison parser...
bison -d bangla_lover.y
if errorlevel 1 (
    echo Error: Bison failed
    pause
    exit /b 1
)
echo ✓ Bison parser generated
echo.

echo Step 2: Generating Flex lexer...
flex -o lex.yy.c bangla_lover.l
if errorlevel 1 (
    echo Error: Flex failed
    pause
    exit /b 1
)
echo ✓ Flex lexer generated
echo.

echo Step 3: Compiling object files...
gcc -c -Wall -g bangla_lover.tab.c
if errorlevel 1 (
    echo Error: Failed to compile parser
    pause
    exit /b 1
)
echo ✓ Parser compiled

gcc -c -Wall -g lex.yy.c
if errorlevel 1 (
    echo Error: Failed to compile lexer
    pause
    exit /b 1
)
echo ✓ Lexer compiled

gcc -c -Wall -g symbol_table.c
if errorlevel 1 (
    echo Error: Failed to compile symbol table
    pause
    exit /b 1
)
echo ✓ Symbol table compiled
echo.

echo Step 4: Linking executable...
gcc -o blpl_compiler.exe bangla_lover.tab.o lex.yy.o symbol_table.o -lm
if errorlevel 1 (
    echo Error: Linking failed
    pause
    exit /b 1
)
echo ✓ Executable created: blpl_compiler.exe
echo.

echo ========================================
echo   Build Successful!
echo ========================================
echo.
echo Ready to use: blpl_compiler.exe
pause
