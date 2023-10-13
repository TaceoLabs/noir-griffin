use crate::GriffinConfig;
use crate::bn254::math::square;
use crate::bn254::math::double;
use crate::bn254::math::mont_ladder;


fn affine_3_mat(mut state: [Field; 3]) -> [Field; 3] {
    let sum = state.reduce(|a,b|a + b);
    state.map(|s|s+sum) 
}

fn affine_3(state: [Field; 3], rc: [Field; 3]) -> [Field; 3] {
    let mut result = affine_3_mat(state);
    for i in 0..3 {
        result[i] += rc[i];
    }
    result
}


fn non_linear_3(config: GriffinConfig<3,11,1>, input: [Field; 3]) -> [Field; 3] {
    let mut output = [input[0],input[1],input[2]];
    output[0] = mont_ladder(output[0], config.d_inv);
    assert(input[0] == output[0].pow_32(config.d));
    output[1] = output[1].pow_32(config.d);

    let mut y01_i = output[0] + output[1];

    //third state element
    let mut l = y01_i;
    let l_square = square(l);
    l *= config.alpha_beta[0][0];
    l += l_square;
    l += config.alpha_beta[0][1];
    output[2] *= l;
    output
}

fn permute_3(config: GriffinConfig<3,11,1>, mut state: [Field; 3]) -> [Field; 3]{
    //no round constant
    state = affine_3_mat(state);
    for r in 0..11 {
        state = non_linear_3(config, state);
        state = affine_3(state, config.rc[r]);
    }
    state = non_linear_3(config, state);
    //no round constant
    state = affine_3_mat(state);
    state
}

#[test]
fn test_affine_3() {
    assert([0x0c,0x0c,0x0c] == affine_3_mat([3,3,3]));
    //assert([0x0bbd0d, 0x051439, 0x1d0509, 0x186a40] == affine_4_mat([2341,5431,76575,214332]));
}

#[test]
fn test_non_linear_3() {
    let config = crate::bn254::consts::x5_3_config();
    let result = non_linear_3(config, [0x0c,0x0c,0x0c]);
    assert(result[0] == 0x2cb96829983dc5a607843ff245abcc153381cc87fc7a322181e8ea7a33f2da15);
    assert(result[1] == 0x000000000000000000000000000000000000000000000000000000000003cc00);
    assert(result[2] == 0x19ab83c7ee1aff2a678f1a04ca74ed6ef32d88e022bf98c030429a37bfd467ce);
}


#[test]
fn test_permute_3() {
    let config = crate::bn254::consts::x5_3_config();
    let result = permute_3(config, [3,3,3]);
    assert(result[0] == 0x132087f636e0e40cfeaa84b07adc71914fb0e162b4214f822aeb18bccce1597c);
    assert(result[1] == 0x22574d8ab0860bad1fc61838e45a80ebd629b786cf3bc982a443f3efee3fa5e7);
    assert(result[2] == 0x26dd774a06d568501694921eaffa2f8846676cd7738a43d17803f46afcf0d34f);
}