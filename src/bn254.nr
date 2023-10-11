mod consts;
mod perm;
mod math;
mod s3;
mod s4;
mod s8;

fn hash_3(input: [Field; 4]) -> Field {
    perm::x5_4(input)[0]
}

fn hash_4(input: [Field; 4]) -> Field {
    perm::x5_4(input)[0]
}

fn hash_8(input: [Field; 4]) -> Field {
    perm::x5_4(input)[0]
}