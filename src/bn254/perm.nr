use crate::bn254::consts;
use crate::bn254::math::affine_first_mat;
use crate::bn254::math::permute;

#[field(bn254)]
pub fn x5_3(input: [Field; 3]) -> [Field; 3] {
    let affine_3_mat = |state: [Field; 3]| {
        let sum = state.reduce(|a,b|a + b);
        state.map(|s|s+sum) 
    };
    permute(consts::x5_3_config(), input, affine_3_mat)
}

#[field(bn254)]
pub fn x5_4(state: [Field; 4]) -> [Field; 4] {
    permute(consts::x5_4_config(), state, affine_first_mat)
}

fn affine_8_mat(mut state: [Field; 8]) -> [Field; 8] {
    //first matrix
    let mut first_four = affine_first_mat([state[0], state[1], state[2], state[3]]);
    let second_four = affine_first_mat([state[4], state[5], state[6], state[7]]);
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
    [state[0] + first_four[0],
        state[1] + first_four[1],
        state[2] + first_four[2],
        state[3] + first_four[3],
        state[4] + first_four[0],
        state[5] + first_four[1],
        state[6] + first_four[2],
        state[7] + first_four[3]]
}

#[field(bn254)]
pub fn x5_8(state: [Field; 8]) -> [Field; 8] {
    permute(consts::x5_8_config(), state, affine_8_mat)
}

#[test]
fn test_permute_3() {
    let result = x5_3([3, 3, 3]);
    assert(result[0] == 0x071662267b811d63d5b5ed1427e38ca8ebc4de6e4eb26bd461d93f1c55c215a5);
    assert(result[1] == 0x26a7dd03a41f144ec7e1fe1469f82b01126a672cdce3d6cd83195436aa515281);
    assert(result[2] == 0x0df5d7a88a7126ae585dd1dcf656a7475afd24cd078489bb218d580b8aeccc3e);
}

#[test]
fn test_permute_3_2() {
    let result = x5_3([0, 1, 2]);
    assert(result[0] == 0x1516cc1e2ac78e1920e897f7da5dd57ed07f88ec34b3f7cdee5df6ff20392c19);
    assert(result[1] == 0x2dc69a9091f39bc37d60bc19c53fef6afc8b2e7f9ab2485d9fb433c5828914cc);
    assert(result[2] == 0x225d885f1464a394680c5328dafa02c45cd17da3048deb9958cac71a228d7ae5);
}

#[test]
fn test_permute_4() {
    let result = x5_4([4, 4, 4, 4]);
    assert(result[0] == 0x21e8a3f3dee45b03f8fe8c335c29acad668ce7a0fffd56526d42ced0d477117d);
    assert(result[1] == 0x0fce77f5bf5329997ebf10835add759bddc5348babd651bdb75dff717ec19851);
    assert(result[2] == 0x1596ac42297fbff53d6840d6bc03699ad5647ba6a58b16eebb0a89f4bd8b8b38);
    assert(result[3] == 0x08e39577f71c17d72c269f4fd3f37a3bfbc838e10f0397f731c070c20b3c0e6b);
}

#[test]
fn test_permute_4_2() {
    let result = x5_4([1, 2, 3, 4]);
    assert(result[0] == 0x011af2d3a0c9e8224b94c4258a1a3be54886409d5060cf0ff164dee208e48d45);
    assert(result[1] == 0x253e5bc2f44ac94b1532525c2c97580b6dd2435e5d8bf919c88b18e55c4967fe);
    assert(result[2] == 0x234c5aa9f2a5b9555b977fdd47cc14f5dbfc9b716412d2507777e21783c204f7);
    assert(result[3] == 0x2be141fbcfde5ca866dfca2f5569be5d7ad3bd6b27ebab997e62de18efcf0a53);
}

#[test]
fn test_permute_8() {
    let result = x5_8([8, 8, 8, 8, 8, 8, 8, 8]);
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
fn test_permute_8_2() {
    let result = x5_8([1, 2, 3, 4, 5, 6, 7, 8]);
    assert(result[0] == 0x058e4a08a32a0759faeb1eb7910ba1adad306c365f30e24838a0ae4d396f148e);
    assert(result[1] == 0x2d2c2aa316608461914ddbcfd834ecfb9c580639995a7b395bfdf687b0430456);
    assert(result[2] == 0x0faa5e0a8b8b88361ce7bfadb618a7972d706277700cd077c71d5d70b0014b8e);
    assert(result[3] == 0x2aca5a3f3f7a876f96056333ed60efda360f87faf0b5d6c8ced97337297a7f84);
    assert(result[4] == 0x22f156b01d16d8026b33ac43744ca649f5e1d55557a535ca26167865ee4401ed);
    assert(result[5] == 0x2294d7914df7e53f3b1158ed6b98e5de7ed9cfc850b3a0359000b9c563053d1f);
    assert(result[6] == 0x0b2226f2b57b78baa214dc4619ea63c3bdc6351fe7e661109279edc66308d0a0);
    assert(result[7] == 0x2d27c100ae5d1ac64f7014a1e55b609186599c1b96ef675b687fb50e294eb5ed);
}

#[test]
fn test_affine_8_mat() {
    assert([0x0180, 0x0120, 0x0180, 0x0120, 0x0180, 0x0120, 0x0180, 0x0120] == affine_8_mat([8, 8, 8, 8, 8, 8, 8, 8]));
}
