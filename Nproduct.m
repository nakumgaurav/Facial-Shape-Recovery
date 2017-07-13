function B = Nproduct(A, M, k)
% Mode-k product (B = A x_k M)
%
% Implemented by Minsik Lee (mlee.paper@gmail.com)
% Last update: 2014-03-19


nt = size(A);
nt = [nt ones(1, k-numel(nt))];
pn = prod(nt(1:k-1));
nn = prod(nt(k+1:end));
if pn == 1
    B = M*reshape(A, [], nn);
elseif nn == 1
    B = reshape(A, pn, [])*M';
else
    A = reshape(A, pn, [], nn);
    B = zeros(pn, size(M, 1), nn);
    tM = M';
    for l=1:nn
        B(:, :, l) = A(:, :, l)*tM;
    end
end
B = reshape(B, [nt(1:k-1) size(M, 1) nt(k+1:end)]);

end
