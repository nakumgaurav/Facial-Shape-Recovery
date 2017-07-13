function F = assignParams(f,params)
n = numel(params)/3;
a = params(1:n); b = params(n+1:2*n); c = params(2*n+1:3*n);
for j = 1:n
    eval(sprintf('f.a%d = a(%d)',j,j));
    eval(sprintf('f.b%d = b(%d)',j,j));
    eval(sprintf('f.c%d = c(%d)',j,j));
end
F = f;
end