function v = expo(bi, bj, ck)
%%Finds the exponential part of the Gaussian Eqn at the specified values of
%%the parameters bi, bj, ck

v = exp(-((bi - bj)/ck)^2);