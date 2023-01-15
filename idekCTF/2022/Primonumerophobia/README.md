# Primonumerophobia

Military training is boring, why not make a crypto challenge? 

**Author. EggRoll**

## Overview

A standard RSA challenge with a fashion prime generation function. 
1. Initialize a $64$-bits LFSR with random states.
2. Get output bits from LFSR, if they form a prime with correct order, return the prime. Otherwise, repeat the process
3. One strange thing is that the program prints out how many trials it takes to find the primes. 

## Exploit

Notice that if lower bits of $q$ is revealed once the lower bits of $p$ is given. Therefore, we simply try all possible lower $32$ bits of $p$ and get $64$ equations about the initial state. That's enough to recover the state. Note that the equations might not be linear independent, but we could still expect there aren't too many solutions :P

:::success
idek{th3_prim3_g3n3r4ti0n_is_c001_but_n0t_s3cur3_QAQ}
:::
