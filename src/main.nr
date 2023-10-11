mod bn254;
use dep::std;

struct GriffinConfig<S,R> {
    d: Field,
    d_inv: Field,
    alpha_beta: [[Field; 2];2],
    mat: [[Field; 4]; 4],
    rc: [[Field; S]; R],
}

fn double(x: Field) -> Field {
    2 * x
}

fn square(x: Field) -> Field {
    x * x
}

fn affine_4_mat(mut state: [Field; 4]) -> [Field; 4] {
    let t_0 = state[0] + state[1];
    let t_1 = state[2] + state[3];
    let t_2 = double(state[1]) + t_1;
    let t_3 = double(state[3]) + t_0;
    let t_4 = double(double(t_1)) + t_3;
    let t_5 = double(double(t_0)) + t_2;
    let t_6 = t_3 + t_5;
    let t_7 = t_2 + t_4;
    state[0] = t_6;
    state[1] = t_5;
    state[2] = t_7;
    state[3] = t_4;
    state

}
fn affine_4(state: [Field; 4], rc: [Field; 4]) -> [Field; 4] {
    let mut result = affine_4_mat(state);
    for i in 0..4 {
        result[i] += rc[i];
    }

    result
}
unconstrained fn d_inv(x: Field, d_inv: Field) -> Field {
    x.pow_32(d_inv)
}

fn non_linear_4(config: GriffinConfig<4,11>, mut input: [Field; 4]) -> [Field; 4] {
    let mut output = [input[0],input[1],input[2],input[3]];
    output[0] = mont_ladder(output[0], config.d_inv);
    assert(input[0] == output[0].pow_32(config.d));
    output[1] = square(square(output[1])) * output[1];

    let mut y01_i = output[0] + output[1];
    let y0 = output[0];

    //third state element
    let mut l = y01_i;
    let l_square = square(l);
    l *= config.alpha_beta[0][0];
    l += l_square;
    l += config.alpha_beta[0][1];
    output[2] *= l;

    let mut l = y01_i + y0 + input[2];
    let l_square = square(l);
    l *= config.alpha_beta[1][0];
    l += l_square;
    l += config.alpha_beta[1][1];
    output[3] *= l;
    output
}

/*

    fn l(y01_i: &mut S, y0: &S, x: &S, i: usize) -> S {
        if i == 0 {
            y01_i.to_owned()
        } else {
            y01_i.add_assign(y0);
            let mut out = y01_i.to_owned();
            out.add_assign(x);
            out
        }
    }
*/

fn permute_4<O>(config: GriffinConfig<4,11>, mut state: [Field; 4]) -> [Field; 4]{
    //no round constant
    state = affine_4_mat(state);
    for r in 0..11 {
        state = non_linear_4(config, state);
        state = affine_4(state, config.rc[r]);
    }
    state = non_linear_4(config, state);
    state = affine_4_mat(state);
    state
}


fn permute<S,R,O>(config: GriffinConfig<S,R>, mut state: [Field; S]) -> [Field; S]{
    //depending on state size
    if S == 4 {
        //affine_4_mat(state)
        state
    } else {
        assert(false);
        state
    }
}

unconstrained fn mont_ladder(x: Field, exp: Field) -> Field {
    let exp_bits = exp.to_be_bits(256);
    let mut x1 = x;
    let mut x2 = x * x;
    let mut found = false;
    for i in 0..256 {
        if exp_bits[i] == 1 {
            if !found {
                found = true;
            } else {
                x1 = x1 * x2;
                x2 = x2 * x2;
            }
        } else {
            if found {
                x2 = x1 * x2;
                x1 = x1 * x1;
            }
        }
    }
    x1
}

fn main(mut input: [Field; 4]) -> pub Field {
    //let config = bn254::consts::x5_4_config();
    //permute_4(config, input)
    //non_linear_4(config, input)
    std::hash::poseidon::bn254::hash_4(input)

}

#[test]
fn test_affine_4_mat() {
    assert([0x40,0x30,0x40,0x30] == affine_4_mat([4,4,4,4]));
    assert([0x0bbd0d, 0x051439, 0x1d0509, 0x186a40] == affine_4_mat([2341,5431,76575,214332]));
}


#[test]
fn test_affine_4() {
    assert([0x40,0x30,0x40,0x30] == affine_4_mat([4,4,4,4]));
    assert([0x0bbd0d, 0x051439, 0x1d0509, 0x186a40] == affine_4_mat([2341,5431,76575,214332]));
}

#[test]
fn inv_test() {
    let config = bn254::consts::x5_4_config();
    let inv = mont_ladder(42, config.d_inv);
    assert(inv.pow_32(5) == 42);
}

#[test]
fn test_non_linear_4() {
    let config = bn254::consts::x5_4_config();
    let result = non_linear_4(config, [0x40,0x30,0x40,0x30]);
    assert(result[0] == 0x2583d7714e3b74553fece7da4af7bfca52635c47d955dc108188ceb122f18c4c);
    assert(result[1] == 0x0f300000);
    assert(result[2] == 0x0bd3054eafa9a668134e8137cdf44412551833a499cfd0c3dae58bf81cc12406);
    assert(result[3] == 0x1a05302cd5768da0a30d4c26fb1ef76635b4bc62f2c52ded729eb26a1334bf7d);
    //l_1=0x2c0a332d56d39fbf6f55f93244950924b5c36b5040b74d46b4f05cbdf1f30491
    //l_2=0x03910b3d7285924b49954b46e2a8baad48f7027141ffb2a8b14c18661f666ea8
}

#[test]
fn test_permute_4() {
    let config = bn254::consts::x5_4_config();
    let result = permute_4(config, [4,4,4,4]);
    assert(result[0] == 0x1e11d0030548ad6a81c0095eafd65e8e957833fe20304c9be082366622d50d6a);
    assert(result[1] == 0x2787cd5abbdb33050b1cce1805c3ee0f2417a0bb7ce62f9fcc79ca8add6bd1b4);
    assert(result[2] == 0x1ea1e510b08660d2573e1229dbaf23a732c455bf7747a2bb6c13a6c333d2cdee);
    assert(result[3] == 0x2986a07f0cb8847d7aaf52e4793cb96e1af447bd85b9e29eef078d13cea80519);
 //   assert(result[0] == 0x22cf010a4b2c4a0f583009b5fdcf2292ff660f447eb78a40f3f99a0b775c0abc);
 //   assert(result[1] == 0x227f80fe662aa90e03e8019f375eabe26d32cd8f63077a66bea18440d170cb78);
 //   assert(result[2] == 0x28a2aee89def488fb9d922eb19704e2c7ec8df04b2f96f95c9df93b7597485d5);
 //   assert(result[3] == 0x026410b961a074b0148afc7acb23818df040e0c0fa167ef375dfb2e3862e498a);
}