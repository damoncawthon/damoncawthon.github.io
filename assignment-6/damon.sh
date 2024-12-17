#!/bin/bash

# Set script to exit on error
set -e

# File names
FARADAY_ASM="faraday.asm"
FTOA_ASM="ftoa.asm"
ATOF_ASM="atof.asm"
OUTPUT="faraday"

# Step 1: Assemble the files with debugging symbols
echo "Assembling $FARADAY_ASM..."
nasm -f elf64 -g -o faraday.o $FARADAY_ASM

echo "Assembling $FTOA_ASM..."
nasm -f elf64 -g -o ftoa.o $FTOA_ASM

echo "Assembling $ATOF_ASM..."
nasm -f elf64 -g -o atof.o $ATOF_ASM

# Step 2: Link the object files into a single executable
echo "Linking object files..."
ld -o $OUTPUT faraday.o ftoa.o atof.o

# Step 3: Run gdb on the output executable
echo "Starting gdb for $OUTPUT..."
gdb ./$OUTPUT
