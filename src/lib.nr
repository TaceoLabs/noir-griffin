mod bn254;

// S is state size {3,4,8}
// R is rounds-1 (because first RC is zero)
// A is S-2, used for the alpha, beta constants during the L-function
struct GriffinConfig<S, R, A> {
    d: Field,
    d_inv: Field,
    alpha_beta: [[Field; 2];A],
    rc: [[Field; S]; R],
}

#[test]
fn test_hash_3() {
    assert(crate::bn254::hash_3([3, 3, 3]) == 0x071662267b811d63d5b5ed1427e38ca8ebc4de6e4eb26bd461d93f1c55c215a5);
}

#[test]
fn test_hash_4() {
    assert(crate::bn254::hash_4([4, 4, 4, 4]) == 0x21e8a3f3dee45b03f8fe8c335c29acad668ce7a0fffd56526d42ced0d477117d);
}

#[test]
fn test_hash_8() {
    assert(crate::bn254::hash_8([8, 8, 8, 8, 8, 8, 8, 8]) == 0x292fb992bfd959e28d73266e8e1b8b13f1c36cd9fe08f47689c01f5813a90c33);
}
