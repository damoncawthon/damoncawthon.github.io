#!/bin/bash

# Author: Damon Cawthon
# Program name: The Hello World Program
# Purpose: This is a Bash script file to assemble, link, and run "The Hello World Program".

# Step 1: Remove old executable and object files if they exist
echo "Removing old executable and object files..."
rm -f *.out *.o *.lis

# Step 2: Assemble the assembly files
echo "Assembling the X86 file faraday.asm..."
nasm -f elf64 -l faraday.lis -o faraday.o faraday.asm

echo "Assembling the X86 file atof.asm..."
nasm -f elf64 -l atof.lis -o atof.o atof.asm

echo "Assembling the X86 file ftoa.asm..."
nasm -f elf64 -l ftoa.lis -o ftoa.o ftoa.asm

# Step 3: Link the object files
echo "Linking the object files into an executable..."
ld -o go.out faraday.o atof.o ftoa.o

# Step 4: Run the program
echo "Executing the program 'The Hello World Program'..."
./go.out
