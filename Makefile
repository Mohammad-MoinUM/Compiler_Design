# ========================================
# Makefile for Bangla Lover (BLPL) Compiler
# ========================================

CC = gcc
CFLAGS = -Wall -g
LEX = flex
YACC = bison

# Output executable
TARGET = blpl_compiler

# Source files
LEX_FILE = bangla_lover.l
YACC_FILE = bangla_lover.y
SYMBOL_TABLE_SRC = symbol_table.c
SYMBOL_TABLE_HDR = symbol_table.h

# Generated files
LEX_C = lex.yy.c
YACC_C = bangla_lover.tab.c
YACC_HDR = bangla_lover.tab.h

# Object files
OBJS = $(YACC_C:.c=.o) $(LEX_C:.c=.o) $(SYMBOL_TABLE_SRC:.c=.o)

# ========================================
# Build targets
# ========================================

.PHONY: all clean test help

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) -o $(TARGET) $(OBJS) -lm
	@echo "✓ Compilation successful! Executable: $(TARGET)"

# Compile Bison parser
$(YACC_C) $(YACC_HDR): $(YACC_FILE)
	$(YACC) -d -o $(YACC_C) $(YACC_FILE)
	@echo "✓ Bison parser generated"

# Compile Flex lexer
$(LEX_C): $(LEX_FILE) $(YACC_HDR)
	$(LEX) -o $(LEX_C) $(LEX_FILE)
	@echo "✓ Flex lexer generated"

# Compile object files
%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

# Clean build artifacts
clean:
	rm -f $(TARGET) $(OBJS) $(LEX_C) $(YACC_C) $(YACC_HDR)
	rm -f blpl_output.c compile_output.txt
	@echo "✓ Cleaned build files"

# Test compilation
test: $(TARGET)
	@echo "\n========================================\n"
	@echo "Testing with input.bl..."
	@echo "========================================\n"
	./$(TARGET) input.bl compile_output.txt
	@echo "\n✓ Test complete! Check compile_output.txt and blpl_output.c"

# Display help
help:
	@echo "========================================\n"
	@echo "  Bangla Lover (BLPL) Compiler - Makefile"
	@echo "========================================\n"
	@echo "Targets:"
	@echo "  make all     - Build the compiler (default)"
	@echo "  make test    - Build and test with input.bl"
	@echo "  make clean   - Remove build artifacts"
	@echo "  make help    - Show this help message"
	@echo ""
