use crate::bn254::consts;
use crate::bn254::math::affine_first_mat;
use crate::bn254::math::permute;

fn x5_3(input: [Field; 3]) -> [Field; 3] {
    let affine_3_mat = |state: [Field; 3]| {
        let sum = state.reduce(|a,b|a + b);
        state.map(|s|s+sum) 
    };
    permute(consts::x5_3_config(), input, affine_3_mat)
}

fn x5_4(state: [Field; 4]) -> [Field; 4] {
    permute(consts::x5_4_config(), state, affine_first_mat)
}

fn affine_8_mat(mut state: [Field; 8]) -> [Field; 8] {
    //first matrix
    let mut first_four = affine_first_mat([state[0],state[1],state[2],state[3]]);
    let second_four = affine_first_mat([state[4],state[5],state[6],state[7]]);
    state = [
        first_four[0],
        first_four[1],
        first_four[2],
        first_four[3],
        second_four[0],
        second_four[1],
        second_four[2],
        second_four[3],
    ];
    //second matrix
    first_four[0] += second_four[0];
    first_four[1] += second_four[1];
    first_four[2] += second_four[2];
    first_four[3] += second_four[3];
    [
        state[0] + first_four[0],
        state[1] + first_four[1],
        state[2] + first_four[2],
        state[3] + first_four[3],
        state[4] + first_four[0],
        state[5] + first_four[1],
        state[6] + first_four[2],
        state[7] + first_four[3],
    ]
}

fn x5_8(state: [Field; 8]) -> [Field; 8] {
    permute(consts::x5_8_config(), state, affine_8_mat)
}



#[test]
fn test_permute_3() {
    let result = x5_3([3,3,3]);
    assert(result[0] == 0x132087f636e0e40cfeaa84b07adc71914fb0e162b4214f822aeb18bccce1597c);
    assert(result[1] == 0x22574d8ab0860bad1fc61838e45a80ebd629b786cf3bc982a443f3efee3fa5e7);
    assert(result[2] == 0x26dd774a06d568501694921eaffa2f8846676cd7738a43d17803f46afcf0d34f);
}

#[test]
fn test_permute_4() {
    let result = x5_4([4,4,4,4]);
    assert(result[0] == 0x21e8a3f3dee45b03f8fe8c335c29acad668ce7a0fffd56526d42ced0d477117d);
    assert(result[1] == 0x0fce77f5bf5329997ebf10835add759bddc5348babd651bdb75dff717ec19851);
    assert(result[2] == 0x1596ac42297fbff53d6840d6bc03699ad5647ba6a58b16eebb0a89f4bd8b8b38);
    assert(result[3] == 0x08e39577f71c17d72c269f4fd3f37a3bfbc838e10f0397f731c070c20b3c0e6b);
}

#[test]
fn test_permute_8() {
    let result = x5_8([8,8,8,8,8,8,8,8]);
    assert(result[0] == 0x292fb992bfd959e28d73266e8e1b8b13f1c36cd9fe08f47689c01f5813a90c33);
    assert(result[1] == 0x15be7e7b4b313ce60976096b41ce9e6f3fd286db341bd79d9b8cecf69fbbc0fa);
    assert(result[2] == 0x25f95734d968ef69612ed123949a67230955daca1993bca94e857bb1c421fe5f);
    assert(result[3] == 0x16d832f1ed234d487f3f7f3eb0040cdecaa47ce9515d59765c35e491fd7b3df7);
    assert(result[4] == 0x2498be1c8c6bba452ee1443108790d1ca9d8e31832282796865bf50581937e3b);
    assert(result[5] == 0x168014916604f11a616eb845d7e8b80d2cc8961fc1f50216f1dc00279dc9df92);
    assert(result[6] == 0x281cc58cbb36bcfef141f3133e15895596df9e30a3666b8a9d5cd58afb343e86);
    assert(result[7] == 0x16e2d89f8e00b204ae028c161c120c941670290ac80f4d233bbf3f76820d070f);
}



#[test]
fn test_affine_8_mat() {
    assert([0x0180, 0x0120, 0x0180, 0x0120, 0x0180, 0x0120, 0x0180, 0x0120] == affine_8_mat([8,8,8,8,8,8,8,8]));
}