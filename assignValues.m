function [a, b, c] = assignValues(f,n)
a = zeros(n,1); b = zeros(n,1); c = zeros(n,1);
for j = 1:n
    a(j) = eval(sprintf('f.a%d', j));
    b(j) = eval(sprintf('f.b%d', j));
    c(j) = eval(sprintf('f.c%d', j));
end
end