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

fn griffin_sponge<I,O>(input: [Field; I]) -> [Field; O] {
    //we hardcode with griffin-3 for the moment
    //therefore we have r=1, c=2

    //absorb
    let mut state = [0; 3];
    for i in 0..input.len() {
        state[0] += input[i];
        state = perm::x5_3(state);
    }

    //squeeze
    let mut output = [0; O];
    output[0] = state[0];
    for i in 1..O {
        state = perm::x5_3(state);
        output[i] = state[0];
    }
    output
}