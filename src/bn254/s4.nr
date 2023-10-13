use crate::GriffinConfig;
use crate::bn254::math::double;
use crate::bn254::math::square;
use crate::bn254::math::mont_ladder;

fn affine_4_mat(mut state: [Field; 4]) -> [Field; 4] {
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

fn affine_4(state: [Field; 4], rc: [Field; 4]) -> [Field; 4] {
    let mut result = affine_4_mat(state);
    for i in 0..4 {
        result[i] += rc[i];
    }
    result
}

fn non_linear_4(config: GriffinConfig<4,10,2>, input: [Field; 4]) -> [Field; 4] {
    let mut output = [input[0],input[1],input[2],input[3]];
    output[0] = mont_ladder(output[0], config.d_inv);
    assert(input[0] == output[0].pow_32(config.d));
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

    //fourth state element
    let mut l = y01_i + y0 + input[2];
    let l_square = square(l);
    l *= config.alpha_beta[1][0];
    l += l_square;
    l += config.alpha_beta[1][1];
    output[3] *= l;
    output
}

fn permute_4(config: GriffinConfig<4,10,2>, mut state: [Field; 4]) -> [Field; 4]{
    //no round constant
    state = affine_4_mat(state);
    for r in 0..10 {
        state = non_linear_4(config, state);
        state = affine_4(state, config.rc[r]);
    }
    state = non_linear_4(config, state);
    //no round constant
    state = affine_4_mat(state);
    state
}

#[test]
fn test_affine_4_mat() {
    assert([0x40,0x30,0x40,0x30] == affine_4_mat([4,4,4,4]));
    assert([0x0bbd0d, 0x051439, 0x1d0509, 0x186a40] == affine_4_mat([2341,5431,76575,214332]));
}

#[test]
fn inv_test() {
    let config = crate::bn254::consts::x5_4_config();
    let inv = mont_ladder(42, config.d_inv);
    assert(inv.pow_32(5) == 42);
}

#[test]
fn test_non_linear_4() {
    let config = crate::bn254::consts::x5_4_config();
    let result = non_linear_4(config, [0x40,0x30,0x40,0x30]);
    assert(result[0] == 0x2583d7714e3b74553fece7da4af7bfca52635c47d955dc108188ceb122f18c4c);
    assert(result[1] == 0x0f300000);
    assert(result[2] == 0x0bbd4148554f2b6d810e78c71f3aa53cdd4484c2a2500b8401da572b7f7ff5ef);
    assert(result[3] == 0x0ff68b6467b51c03739243d481f14d7a9ff986a101f04fbd7d126cb437a525de);
}

#[test]
fn test_permute_4() {
    let config = crate::bn254::consts::x5_4_config();
    let result = permute_4(config, [4,4,4,4]);
    assert(result[0] == 0x21e8a3f3dee45b03f8fe8c335c29acad668ce7a0fffd56526d42ced0d477117d);
    assert(result[1] == 0x0fce77f5bf5329997ebf10835add759bddc5348babd651bdb75dff717ec19851);
    assert(result[2] == 0x1596ac42297fbff53d6840d6bc03699ad5647ba6a58b16eebb0a89f4bd8b8b38);
    assert(result[3] == 0x08e39577f71c17d72c269f4fd3f37a3bfbc838e10f0397f731c070c20b3c0e6b);
}