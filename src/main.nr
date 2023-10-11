mod bn254;
use dep::std;

struct GriffinConfig<S,R> {
    d: Field,
    d_inv: Field,
    alpha_beta: [[Field; 2];2],
    mat: [[Field; 4]; 4],
    rc: [[Field; S]; R],
}

fn main(mut input: [Field; 4]) -> pub Field {
    //let config = bn254::consts::x5_4_config();
    //permute_4(config, input)
    //non_linear_4(config, input)
    crate::bn254::hash_4(input)

}