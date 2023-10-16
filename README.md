# Noir-Griffin for BN254

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

This repository contains a Noir crate implementing the zk-friendly hash function Griffin for Noir's native curve BN254.

Griffin utilizes low-degree equivalence, optimized for fast prover times. These designs rely on the observation that it is possible to prove the heavy computation $y=x^{1/d}$ by constraining $y^d=x$. If $d$ is small (5 for this implementation) and the prime field is large, then $1/d$ is a considerably large exponent with many multiplications involved. Using the power map $y=x^{1/d}$ leads to fewer rounds to achieve a target security threshold.

Especially in contrast to older designs, which use the power map $y=x^d$ with a relatively small exponent (like Poseidon), Griffin has a drastically improved prover time. See the Performance section below.

As proposed in the Griffin paper, we provide an API for using Griffin in sponge mode. We use the instantiation with state size 3, bitrate $r=2$, and capacity $c=1$.

For further information, we refer to the [Griffin Paper](https://eprint.iacr.org/2022/403.pdf).

## Performance

We instantiated this Griffin instance with $d$=5 and hence $1/d=0x26b6a528b427b35493736af8679aad17535cb9d394945a0dcfe7f7a98ccccccd$. Griffin has an internal state of $t \in {3, 4t}$ for a positive integer $t$. We provide an implementation for state sizes 3, 4, and 8. The following table shows the constraints obtained by `nargo info` for our implementation and the corresponding hashes from the standard library that work on Field elements.

| Input | Griffin | Poseidon | Pedersen | mimc_bn254 | `hash_to_field` (blake2) |
| ----- | ------- | -------- | -------- | ---------- | ------------------------ |
| 3     | 172     | 2280     | 3112     | 1375       | 8958                     |
| 4     | 279     | 2751     | 3260     | 1927       | 9088                     |
| 8     | 591     | 3938     | 3848     | 4506       | 15287                    |

Griffin heavily outperforms its peers for all instantiations. We also compare Griffin in sponge mode with Poseidon in sponge mode as provided by the standard library in the following table:

| Input | Griffin | Poseidon |
| ----- | ------- | -------- |
| 1     | 168     | 2728     |
| 2     | 269     | 2733     |
| 4     | 548     | 2751     |
| 8     | 1106    | 5525     |
| 16    | 2222    | 11073    |

**Note**: Our sponge API allows an arbitrarily long output stream. The sponge implementation from the standard library only allows a single output Field (version 0.10.5). Therefore, we compare the performance with a single output element.

## Installation

In your `Nargo.toml` file, add the following dependency:

```toml
[dependencies]
griffin = { tag = "v0.1.0", git = "https://github.com/TaceoLabs/noir-griffin" }
```

## Examples

You have to include
