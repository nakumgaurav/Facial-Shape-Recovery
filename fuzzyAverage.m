function mu = fuzzyAverage(i,j)

[c_L, c_R] = MCF(i,j);
k = numel(c_L)-1;
alpha = 0:(1/k):1;
sum_L = 0;
sum_R = 0;

for i = 1:k+1
    sum_L = sum_L + alpha(i)*c_L(i);
    sum_R = sum_R + alpha(i)*c_R(i);
end

mu = (sum_L + sum_R)/(2*(sum(alpha)));


