#!/bin/bash

# Author: Damon Cawthon
# Program name: The Hello World Program
# Purpose: Debug the program using GDB

# Step 1: Remove old executable and object files if they exist
echo "Removing old executable and object files..."
rm -f *.out *.o *.lis

# Step 2: Assemble the assembly files with debugging symbols
echo "Assembling the X86 file faraday.asm with debug symbols..."
nasm -f elf64 -g -F dwarf -l faraday.lis -o faraday.o faraday.asm

echo "Assembling the X86 file atof.asm with debug symbols..."
nasm -f elf64 -g -F dwarf -l atof.lis -o atof.o atof.asm

echo "Assembling the X86 file ftoa.asm with debug symbols..."
nasm -f elf64 -g -F dwarf -l ftoa.lis -o ftoa.o ftoa.asm

# Step 3: Link the object files
echo "Linking the object files into an executable..."
ld -o go.out faraday.o atof.o ftoa.o

# Step 4: Run the program with GDB
echo "Debugging the program 'The Hello World Program' with GDB..."
gdb --quiet --args ./go.out << EOF
# Set a catch for segmentation faults
catch signal SIGSEGV

# Run the program
run

# If a segfault occurs, print backtrace
bt

# Quit GDB
quit
EOF