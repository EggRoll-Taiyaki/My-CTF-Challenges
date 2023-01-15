#!/usr/bin/env python3

from pwn import *

server = process("./server.py")
# server = remote("127.0.0.1", 1337)

"""
	Check the welcome message
"""
server.recvuntil(b"I'll give you 2023 consecutive outputs of the RNG,")
server.recvuntil(b"you just need to recover the seed. Sounds possible, right?")

"""
	Check whether the parameters are sent
"""
server.recvuntil(b"a = ")
server.recvuntil(b"b = ")
server.recvline()

"""
	Check the outputs
"""
for _ in range(2023):
	r = server.recvline()
server.sendlineafter(b"Guess the seed: ", b"0")
server.recvuntil(b"Nope :<")
