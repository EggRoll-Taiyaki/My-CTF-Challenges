# Chronophobia

Motto ... motto hayaku!

**Author. EggRoll** 

## Overview

We are asked to efficiently calculate veriable delay function (VDF): $$f(t) \equiv t^{2^{2^{d}}} \pmod{pq}$$ It's believe to be hard as factoring the modulus. To make it solvable, the server provides a broken oracle that computes the VDF of given input, but only returns the higher bits of the result. For convenience, let's define the approaximation to be another function $\tilde{f}$

## Key Observation

Because we are given higher bits, it's natural to think about LLL, which is used to find `relatively small` things. The naive approach is taking the polynomial $x^{2^{2^{d}}} - \tilde{f}(t)$ However, the degree $2^{2^{d}}$ is too large, we would get nothing by Coppersmith. 

This suggests us to construct other equations about $\tilde{f}$. **Remember that RSA encryption is homomorphic**, in particular,  we have $$f(a)f(t) \equiv f(at) \pmod{pq}$$ 

## Hidden Number Problem with Hidden Multiplier

Let's reduce the challenge to a variation of Hidden number problem (HNP). 

:::warning
Given modulus $m$, and approximations of $a_{i}$ and $a_{i}s$, say $A_{i}$ and $B_{i}$, respectively. In other words, we have two inequalities $$|a_{i} - A_{i}|, \quad |a_{i}s - B_{i}| < \Delta$$ for some small $\Delta$. Find out the hidden number $s$.
:::


The idea to solve this variation is similar to what we do for Approximate GCD. Denote the differences of approaximations and the exact values by $x_{i}$ and $y_{i}$, respectively. Therefore, $a_{i}=A_{i}+x_{i}$ and $a_{i}s = B_{i}+y_{i}$. Now, we rewrite the equations like $$(A_{i}+x_{i})s \equiv B_{i}+y_{i}, \quad (A_{j}+x_{j})s \equiv B_{j}+y_{j} \pmod{m} $$ Perform cross-multiplcation,  we get $$(A_{i}+x_{i})(B_{j}+y_{j}) \equiv (A_{j}+x_{j})(B_{i}+y_{i}) \pmod{m}$$ After simplification, we obtain the equations $$B_{j}x_{i}-B_{i}x_{j}-A_{j}y_{i}+A_{i}y_{j}+(A_{i}B_{j}-A_{j}B_{i}) \equiv x_{j}y_{i}-x_{i}y_{j} \pmod{m}$$ As $x_{i},x_{j},y_{i},y_{j}$ are small, one can recover them by LLL.

## Lattice Construction

Here, we construct the corresponding lattice for the derived equations. To make it more clear, we will illustrate the method with a small example. Suppose we query the oracle to get $3$ equations.

### Step 1. List Conditions

1. All inequalities we have, $$B_{j}x_{i}-B_{i}x_{j}-A_{j}y_{i}+A_{i}y_{j}+(A_{i}B_{j}-A_{j}B_{i}) \pmod{m} << m$$ Or equivalently, $$B_{j}x_{i}-B_{i}x_{j}-A_{j}y_{i}+A_{i}y_{j}+(A_{i}B_{j}-A_{j}B_{i}) - k_{i,j}m$$ is relatively small compared to $m$.
2. The variables and their bounds. 

### Step 2. Put Inequalities in Lattice

:::info
**Tip.** Remember that LLL searches the linear combination of the rows. This means that each inequality is represented by a column while the rows correspond to variables.
:::

Consider $1$ as variable and the constants are the coefficients, and the corresponding variables for rows are $x_{1}, x_{2}, x_{3}, y_{1}, y_{2}, y_{3}, 1, k_{1, 2}, k_{2, 3}, k_{1, 3}$ (in order). 

$$\begin{bmatrix} B_{2} & B_{3} & 0 \\ -B_{1} & 0 & B_{3} \\ 0 & -B_{1} & -B_{2} \\ -A_{2} & -A_{3} & 0 \\ A_{1} & 0 & -A_{3} \\ 0 & A_{1} & A_{2} \\ A_{1}B_{2}-A_{2}B_{1} & A_{1}B_{3}-A_{3}B_{1} & A_{2}B_{3}-A_{3}B_{2} \\ m & 0 & 0 \\ 0 & m & 0 \\ 0 & 0 & m \end{bmatrix}$$

### Step 3. Bounds the Variables

We may consider the bounds as addditional inequalities and so our matrix becomes 

$$\begin{bmatrix} B_{2} & B_{3} & 0 & 1 & 0 & 0 & 0 & 0 & 0 & 0 \\ -B_{1} & 0 & B_{3} & 0 & 1 & 0 & 0 & 0 & 0 & 0 \\ 0 & -B_{1} & -B_{2} & 0 & 0 & 1 & 0 & 0 & 0 & 0 \\ -A_{2} & -A_{3} & 0 & 0 & 0 & 0 & 1 & 0 & 0 & 0 \\ A_{1} & 0 & -A_{3} & 0 & 0 & 0 & 0 & 1 & 0 & 0 \\ 0 & A_{1} & A_{2} & 0 & 0 & 0 & 0 & 0 & 1 & 0 \\ A_{1}B_{2}-A_{2}B_{1} & A_{1}B_{3}-A_{3}B_{1} & A_{2}B_{3}-A_{3}B_{2} & 0 & 0 & 0 & 0 & 0 & 0 & 1 \\ m & 0 & 0 & 0 & 0 & 0 & 0 & 0 & 0 & 0 \\ 0 & m & 0 & 0 & 0 & 0 & 0 & 0 & 0 & 0 \\ 0 & 0 & m & 0 & 0 & 0 & 0 & 0 & 0 & 0 \end{bmatrix}$$

### Step 4. Adjustment

:::info
**Tip.** The objective of LLL is minimizing the norm, thus, whenever there is a column whose entries are much bigger, then LLL would focus on minimizing the column. In other words, it will ignore the other constraints. To avoid such tragedy, make sure that the components of the target row vector are in the same order.    
:::

Our target vector is $$\left(x_{1}y_{2}-x_{2}y_{1}, x_{1}y_{3}-x_{3}y_{1}, x_{2}y_{3}-x_{3}y_{2}, x_{1}, x_{2}, x_{3}, y_{1}, y_{2}, y_{3}, 1\right)$$ The orders of them are listed below $$\Delta^2, \Delta^2, \Delta^2, \Delta, \Delta, \Delta, \Delta, \Delta, \Delta, 1$$

Clearly, we could make them in the same order by multiplying the columns by $1, 1, 1, \Delta, \Delta, \Delta, \Delta, \Delta, \Delta$ and $\Delta^2$, respectively.

$$\begin{bmatrix} B_{2} & B_{3} & 0 & \Delta & 0 & 0 & 0 & 0 & 0 & 0 \\ -B_{1} & 0 & B_{3} & 0 & \Delta & 0 & 0 & 0 & 0 & 0 \\ 0 & -B_{1} & -B_{2} & 0 & 0 & \Delta & 0 & 0 & 0 & 0 \\ -A_{2} & -A_{3} & 0 & 0 & 0 & 0 & \Delta & 0 & 0 & 0 \\ A_{1} & 0 & -A_{3} & 0 & 0 & 0 & 0 & \Delta & 0 & 0 \\ 0 & A_{1} & A_{2} & 0 & 0 & 0 & 0 & 0 & \Delta & 0 \\ A_{1}B_{2}-A_{2}B_{1} & A_{1}B_{3}-A_{3}B_{1} & A_{2}B_{3}-A_{3}B_{2} & 0 & 0 & 0 & 0 & 0 & 0 & \Delta^2 \\ m & 0 & 0 & 0 & 0 & 0 & 0 & 0 & 0 & 0 \\ 0 & m & 0 & 0 & 0 & 0 & 0 & 0 & 0 & 0 \\ 0 & 0 & m & 0 & 0 & 0 & 0 & 0 & 0 & 0 \end{bmatrix}$$

Now, you are able to capture the flag!

:::success
idek{St@rburst_str3@m!!!}
:::
