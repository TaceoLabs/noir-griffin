use crate::bn254::consts;
use crate::bn254::s4::permute_4;




fn x5_4(state: [Field; 4]) -> [Field; 4] {
    permute_4(consts::x5_4_config(), state)
}
