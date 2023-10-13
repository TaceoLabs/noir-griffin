use crate::bn254::consts;
use crate::bn254::s3::permute_3;
use crate::bn254::s4::permute_4;


fn x5_3(state: [Field; 3]) -> [Field; 3] {
    permute_3(consts::x5_3_config(), state)
}

fn x5_4(state: [Field; 4]) -> [Field; 4] {
    permute_4(consts::x5_4_config(), state)
}
