mod consts;
mod perm;
mod math;

fn hash_3(input: [Field; 3]) -> Field {
    perm::x5_3(input)[0]
}

fn hash_4(input: [Field; 4]) -> Field {
    perm::x5_4(input)[0]
}

fn hash_8(input: [Field; 8]) -> Field {
    perm::x5_8(input)[0]
}