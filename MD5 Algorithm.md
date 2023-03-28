MD-5 Algorithm

WHAT IS CRYPTOGRAPHY?
Cryptography is technique of securing information and communications through use of codes. Thus, preventing unauthorized access to information.
Features of cryptography:
1.Confidentiality: Information can only be accessed by the person for whom it is intended and no other person except him can access it.
2.Integrity: Information cannot be modified in storage or transition between sender and intended receiver without any addition to information being detected.

WHAT IS HASHING?
Hashing uses a hash function to convert standard data into an unrecognizable format. These hash functions are a set of mathematical calculations that transform the original information into their hashed values, known as the hash digest or digest in general. The digest size is always the same for a particular hash function like MD5 or SHA256, irrespective of input size.

MD5 (Message Digest 5):
MD5 is a cryptographic hash function algorithm that takes the message as input of any length and changes it into a fixed-length message of 128 bits (16 bytes). MD5 algorithm stands for the message-digest algorithm. MD5 was developed as an improvement of MD4, with advanced security purposes. 

MD5 Algorithm:

•	Step1: Append Padding Bits:
Padding means adding extra bits to the original message. In MD5 padding is done such that the total bits are 64 less, being a multiple of 512 bits length. In padding bits, the only first bit is 1, and the rest of the bits are 0.
Length (original message + padding bits) = 512 * i – 64 where i = 1,2,3 . . . 

•	Step 2: Append Length bits:
After padding, 64 bits are inserted at the end, which is used to record the original input length. The resulting message has a length multiple of 512 bits.

•	Step 3: Initialize MD buffer:
A four-word buffer (A, B, C, D) is used to compute the values for the message digest. Here A, B, C, D are 32- bit registers.

•	Step 4: Processing message in 16-word block
MD5 uses the auxiliary functions, which take the input as three 32-bit numbers and produce 32-bit output. These functions use logical operators like OR, XOR, NOR.
F (B, C, D):	(B AND C) OR ((NOT B) AND (D))
G (B, C, D):  (B AND D) OR (C AND (NOT D))
H (B, C, D):	B XOR C XOR D
I (B, C, D): 	C XOR (B OR (NOT D))

After applying the function an operation is performed on each block. For performing operations:
1. Add modulo 232
2.D[i] – 32-bit message.
3.B[i] – 32-bit constant.
4.<<<n – Left shift by n bits.
The content of four buffers is mixed with the input and 16 rounds are performed using 16 basic operations. After all rounds are performed, the buffer A, B, C, D contains the MD5 output starting with lower bit A and ending with higher bit D.

WHY MD5?
1.	Easier to compare and store these smaller hashes.
2.	It is a widely used algorithm for one-way hashes used to verify without necessarily giving the original value.
3.	 It can perform the message digest of a message having any number of bits.

WHY IS MD5 NOT IDEAL?
1. MD5 has been prone to hash collision weakness, i.e., it is possible to create the same hash function for two different inputs.
 2. MD5 provides no security over these collision attacks. Instead of MD5, SHA (Secure Hash Algorithm, which produces 160-bit message digest) is now used for generating the hash function.
3. Moreover, MD5 is quite slower than the optimized SHA algorithm. SHA is much secure than the MD5 algorithm.

