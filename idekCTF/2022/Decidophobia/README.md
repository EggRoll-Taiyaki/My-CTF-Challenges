# Decidophobia

It's hard to decide which prime we should get back from Mercury, isn't it?

**Author. EggRoll**

## Overview

The server generates a random ticket $t$ and encrypts it by RSA $$c \equiv t^e \pmod{n = pqr}$$ Here $p,q,r$ are $512$-bits primes. In addition, we are given an oblivious transfer (OT). First, it generates two $384$-bits primes $P, Q$ and computes the decryption key $d$ for public key $65537$. Then it gives us three random number and asks us to provide $v$. After that, it returns the following values $$ (v-x_1)^d + p, \quad (v-x_2)^d + q, \quad (v-x_3)^d + r \pmod{PQ} $$ Our goal is to factor the RSA modulus according to the results from OT and reveal the secret number $t$ to get the flag. 

## Trick for Oblivious Transfer 

If you encountered RSA-based OT challenges before (like [zer0pts CTF 2022 OK](https://hackmd.io/@theoldmoon0602/SJrf0HPMq)), then you must know that the sum of two secrets (for instance, $p+q$ in our case) can be recovered by sending the median of two corresponding random numbers (for $p+q$, they are $x_1$ and $x_2$). To be precise, let's choose $v$ to be the median of $x_1$ and $x_2$, then we have $$v-x_1 = \frac{-x_1+x_2}{2} = -\left(\frac{x_1-x_2}{2}\right) = -(v-x_2)$$ It follows that $(v-x_1)^{d} = -(v-x_2)^{d}$ and $$p+q = \left((v-x_1)^d + p\right) + \left((v-x_2)^d + q\right) \pmod{PQ}$$ From this equation, there are only few possbilities of $p+q$.

## Coppersmith Time

With the sum $s$ of two prime factors $p, q$, it's straightforward to come up with such technique. Recall the main theorem,

:::warning
For an integer $N$, who has a divisor $b \ge N^{\beta}$ for some constant $\beta$. If a polynomial $f(x)$ with degree $\delta$, then all small solutions to the following $$f(x) \equiv 0 \pmod{b}, \quad |x| \le c\cdot N^{\frac{\beta^2}{\delta}}$$ could be found in polynomial time.
:::

For reference, I personally recommend the [survey by mimoo](https://github.com/mimoo/RSA-and-LLL-attacks/blob/master/survey_final.pdf). 

We consider the polynomial $f(x) = x(s-x)$. When $x=p$, $f(x)$ is a multiple of $pq$. To see whether $p$ could be found by Coppersmith with non-negligible probability, we are going to estimate the theoretical bound step-by-step. 
1. $\beta$ is at most $\frac{1024}{1535}$ because $p,q,r$ are $512$-bits 
2. $\delta$ is the degree of the polynomial, which is $2$
3. $n^{\frac{\beta^2}{\delta}}$ is at most $$2^{1536 \cdot \frac{\left(\frac{1024}{1535}\right)^2}{2}} \sim 2^{341.78}$$ This value is far from the lower bound of $p$, so we don't expect that the prime factor could be found in this way.

## Key Observation

Notice that the prime factors are only $512$-bits, so if Mercury wants to give us only a prime factor through OT, then $512$-bits modulus $PQ$ is enough. But in our case, the modulus $PQ$ has $768$ bits instead, we expect that it's possible to retrieve more infrmation.

## Improve the Trick

What we learned from the previous approach? When there is a linear relationship between $(v_k-x_1)^d$ and $(v_k-x_2)^d$, then a linear combination of the secrets is leaked. To control the relation, let's assume $$k(v_k-x_1)^d = (v_k-x_2)^d$$ for some constant $k$. Note that $d$ is the decryption key of $e$, the above equation is equivalent to $$(k^ev_k-k^ex_1)^d = (v_k-x_2)^d \longleftarrow v_k = \frac{k^ex_1-x_2}{k^e-1}$$ Now, we simply take $k=-2^{256}$ to get a $768$-bits information about $p, q$.

## Happy Time

So we have $p+2^{256}q$ now and this is enough to recover $p, q$. Write $$p+2^{256}q = q_{high} \times 2^{512} + s \times 2^{256} + p_{lower}$$ Now, consider the polynomial $$f(x) = (q_{high} \times 2^{256} + (s-x))(x \times 2^{256} + p_{lower}) \pmod{N} $$ 

1. $\beta$ is at least $\frac{1022}{1534}$ because $p,q,r$ are $512$-bits 
2. $\delta$ is the degree of the polynomial, which is $2$
3. $n^{\frac{\beta^2}{\delta}}$ is at least $$2^{1533 \cdot \frac{\left(\frac{1022}{1534}\right)^2}{2}} \sim 2^{340.22}$$ 

Because our root $p_{high}$ is less than $2^{256}$, we may expect that it will be found! Finally, we just need to decrpyt the ticket and send it to server to capture the flag :)

:::success
idek{H0n3sty_1s_th3_b3st_p0l1cy?_N0p3_b3c4us3_w3_ar3_h@ck3rs!}
:::
