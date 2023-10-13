mod bn254;
use dep::std;

// S is state size {3,4,8}
// R is rounds-1 (because first RC is zero)
// A is S-2
struct GriffinConfig<S, R, A> {
    d: Field,
    d_inv: Field,
    alpha_beta: [[Field; 2];A],
    mat: [[Field; S]; S],
    rc: [[Field; S]; R],
}

fn main(mut input: [Field; 3]) -> pub Field {
    //permute_4(config, input)
    crate::bn254::hash_3(input)

}