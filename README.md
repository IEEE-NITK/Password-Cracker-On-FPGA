# Password Cracker on FPGA

This repository contains a password cracker implemented in Verilog that performs a dictionary attack using various hashing algorithms. The project targets FPGA platforms and is designed to crack passwords in a fast and efficient manner.
----------------

## Features
- Supports SHA256.
- Dictionary attack approach to cracking passwords.

## Currently Under Progress:
-  MD4 and MD5 hash algorithms
- Implementation on an FPGA platform for maximum performance

## Requirements
- FPGA development board
- Verilog compiler (Vivado)
- Dictionary file containing possible passwords

### MD5 Algorithms
- MD-5 is a cryptographic hash function algorithm that takes the message as input of any length and changes it into a fixed-length message.
- The algo involves four main steps namely-
    - Appending Padding bits- Padding means adding extra bits to the original message.
    - Appending Length bits- After padding, 64 bits are inserted at the end, which is used to record the original input length. 
    - Initializing MD buffers- A four-word buffer (A, B, C, D) is used to compute the values for the message digest.
    - Processing each block- Each 512-bit block gets broken down further into 16 sub-blocks of 32 bits each. There are         four rounds of operations, with each round utilizing all the sub-blocks, the buffers, and a constant array value. 
        - The operations that are performed are:
            - Add modulo 2^ (32)
            - D[i] – 32-bit message.
            - B[i] – 32-bit constant.
            - <<<n – Left shift by n bits.
        - Auxiliary Functions: Auxiliary functions take three inputs (32-bits word) and give an output of 32-bit word. These functions apply logical AND, OR and XOR to the inputs. The non-linear process above is different for each round of the sub-block.
            - Round 1: (b AND c) OR ((NOT b) AND (d))
            - Round 2: (b AND d) OR (c AND (NOT d))
            - Round 3: b XOR c XOR d
            - Round 4: c XOR (b OR (NOT d))


