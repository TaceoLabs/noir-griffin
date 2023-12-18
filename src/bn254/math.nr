use crate::GriffinConfig;

fn double(x: Field) -> Field {
    2 * x
}

fn square(x: Field) -> Field {
    x * x
}

unconstrained fn mont_ladder_unconstrained(x: Field, exp: Field) -> Field {
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
        } else if found {
            x2 = x1 * x2;
            x1 = x1 * x1;
        }
    }
    x1
}

fn mont_ladder<S, R, A>(config: GriffinConfig<S, R, A>, x: Field) -> Field {
    let y = mont_ladder_unconstrained(x, config.d_inv);
    assert(x == y.pow_32(config.d));
    y
}

#[field(bn254)]
pub(crate) fn affine_first_mat(mut state: [Field; 4]) -> [Field; 4] {
    let t_0 = state[0] + state[1];
    let t_1 = state[2] + state[3];
    let t_2 = double(state[1]) + t_1;
    let t_3 = double(state[3]) + t_0;
    let t_4 = double(double(t_1)) + t_3;
    let t_5 = double(double(t_0)) + t_2;
    state[0] = t_3 + t_5;
    state[1] = t_5;
    state[2] = t_2 + t_4;
    state[3] = t_4;
    state
}

#[field(bn254)]
pub(crate) fn affine<S>(mut state: [Field; S], rc: [Field; S], affine_mat: fn([Field; S]) -> [Field; S]) -> [Field; S] {
    state = affine_mat(state);
    for i in 0..S {
        state[i] += rc[i];
    }
    state
}

fn non_linear<S, R, A>(config: GriffinConfig<S, R, A>, mut state: [Field; S]) -> [Field; S] {
    let mut output = state;
    output[0] = mont_ladder(config, output[0]);
    output[1] = output[1].pow_32(config.d);

    let mut y01_i = output[0] + output[1];
    let y0 = output[0];

    //third state element
    let mut l = y01_i;
    let l_square = square(l);
    l *= config.alpha_beta[0][0];
    l += l_square;
    l += config.alpha_beta[0][1];
    output[2] *= l;

    for r in 3..S {
        y01_i += y0;
        let mut l = y01_i + state[r - 1];
        let l_square = square(l);
        l *= config.alpha_beta[r-2][0];
        l += l_square;
        l += config.alpha_beta[r-2][1];
        output[r] *= l;
    }
    output
}

#[field(bn254)]
pub(crate) fn permute<S, R, A>(config: GriffinConfig<S, R, A>, mut state: [Field; S], affine_mat: fn([Field; S]) -> [Field; S]) -> [Field; S] {
    //no round constant
    state = affine_mat(state);
    for r in 0..R {
        state = non_linear(config, state);
        state = affine(state, config.rc[r], affine_mat);
    }
    state = non_linear(config, state);

    //no round constant
    state = affine_mat(state);
    state
}

#[test]
fn inv_test() {
    let config = crate::bn254::consts::x5_4_config();
    let inv = mont_ladder(config, 42);
    assert(inv.pow_32(5) == 42);
}

#[test]
fn test_non_linear_4() {
    let config = crate::bn254::consts::x5_4_config();
    let result = non_linear(config, [0x40, 0x30, 0x40, 0x30]);
    assert(result[0] == 0x2583d7714e3b74553fece7da4af7bfca52635c47d955dc108188ceb122f18c4c);
    assert(result[1] == 0x0f300000);
    assert(result[2] == 0x0bbd4148554f2b6d810e78c71f3aa53cdd4484c2a2500b8401da572b7f7ff5ef);
    assert(result[3] == 0x0ff68b6467b51c03739243d481f14d7a9ff986a101f04fbd7d126cb437a525de);
}

#[test]
fn test_non_linear_8() {
    let config = crate::bn254::consts::x5_8_config();
    let result = non_linear(config, [0x0180, 0x0120, 0x0180, 0x0120, 0x0180, 0x0120, 0x0180, 0x0120]);
    assert(result[0] == 0x290e81e04f49eb2256b83a2e09d63fcd3ecfb0c77f3af3b1bfefdf6077e5b429);
    assert(result[1] == 0x000000000000000000000000000000000000000000000000000001cd52000000);
    assert(result[2] == 0x20e39fb5c23dd899498ebc4edf52492669492f78c8ba96a15164207f76fdd5e1);
    assert(result[3] == 0x2fe1ad915c279c3493fcfd21a5c7a6b926de8e758cbe4c3f981e478dab4ef214);
    assert(result[4] == 0x1aff7bb565d780b45e1641ee67dd6fbe81fcf2e7ee5eaf328a2214640f1c1df8);
    assert(result[5] == 0x03ef136f2245cb9780000af3f216a2111ef8a2d021acfa1b7455417cd8919b44);
    assert(result[6] == 0x251f975ba89701a1adcab02c9c81505dadf9d78460477ec24f9ccb6fc4b90dcf);
    assert(result[7] == 0x0d551cf1f5ef6ea5ecf9fa9a6970fb1f60e9f5e92f9f95c372dfc3495a4ffb93);
}
