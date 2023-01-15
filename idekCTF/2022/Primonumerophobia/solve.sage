# from output import *
from test import *
from Crypto.Util.number import *

class LFSR():

	def __init__(self, taps, initial_state):

		d = max(taps)
		self.taps = [d-t for t in taps]
		# self.state = [random.randint(0, 1) for _ in range(d)]
		self.state = initial_state

	def _sum(self, L):

		res = 0
		for t in L:
			res = res + t
		return res % 2

	def next(self):

		s = self.state[0]
		self.state = self.state[1:] + [self._sum([self.state[t] for t in self.taps])]
		return s

	def getPrime(self, nbits):

		while True:
			p = int("".join([str(self.next()) for _ in range(nbits)]), 2)
			if isPrime(p) and p > 2**(nbits-1):
				return p

taps = [47, 43, 41, 37, 31, 29, 23, 19, 17, 13, 11, 7, 5, 3, 2]
nbits = 512

d = max(taps)
k = (d+1) // 2
taps = [d-t for t in taps]
M = Matrix(GF(2), d, d)
for i in range(d-1):
	M[i, i+1] = 1
for t in taps:
	M[-1, t] = 1

for i in range(447, 448):	
	eqns = matrix(GF(2), [mtr[0] for mtr in [M^(nbits - k + j) for j in range(k)] + [M^(nbits*i + nbits - k + j) for j in range(d-k)]])
	ker = eqns.right_kernel()

	print(len(ker))

	# for p_lower in range(1, 2**k, 2):
	for p_lower in range(1, 2**k, 2):
		q_lower = inverse_mod(p_lower, 2**k) * n % 2**k
		target = vector(GF(2), [int(x) for x in bin(p_lower)[2:].zfill(k)] + [int(x) for x in bin(q_lower)[2:].zfill(k)][:d-k])	

		if p_lower % 2**14 == 1:
			print((p_lower - 1) >> 14)

		try:
			res = eqns.solve_right(target)
		except:
			continue

		possible_seeds = [list(res + v) for v in ker]
		for seed in possible_seeds:
			lfsr = LFSR([47, 43, 41, 37, 31, 29, 23, 19, 17, 13, 11, 7, 5, 3, 2], seed)
			p = int("".join([str(lfsr.next()) for _ in range(nbits)]), 2)
			if n % p == 0:
				q = n // p
				flag = long_to_bytes(power_mod(enc, inverse_mod(0x10001, (p-1)*(q-1)), n))
				print(flag)
				exit()
