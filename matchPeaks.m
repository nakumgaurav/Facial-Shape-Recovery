function F = matchPeaks(f,pks)
%%Match the peaks of the original and fitted data in order to get a better
%%fit to the data
n = numel(pks);

V = zeros(n);
for i = 1:n
    for j = 1:n
        bi = eval(sprintf('f.b%d',i));
        bj = eval(sprintf('f.b%d',j));
        cj = eval(sprintf('f.c%d',j));
        V(i,j) = expo(bi,bj,cj);
    end
end

a = pinv(V) * pks';

for i = 1:n
    eval(sprintf('f.a%d = a(%d);',i,i)); 
end

F = f;
