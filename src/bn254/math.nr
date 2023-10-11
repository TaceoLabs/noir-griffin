fn double(x: Field) -> Field {
    2 * x
}

fn square(x: Field) -> Field {
    x * x
}

unconstrained fn mont_ladder(x: Field, exp: Field) -> Field {
    let exp_bits = exp.to_be_bits(256);
    let mut x1 = x;
    let mut x2 = x * x;
    let mut found = false;
    for i in 0..256 {
        if exp_bits[i] == 1 {
            if !found {
                found = true;
            } else {
                x1 = x1 * x2;
                x2 = x2 * x2;
            }
        } else {
            if found {
                x2 = x1 * x2;
                x1 = x1 * x1;
            }
        }
    }
    x1
}