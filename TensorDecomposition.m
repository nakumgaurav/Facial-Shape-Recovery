function [C, U] = TensorDecomposition(C)
% function [C U] = TensorDecomposition(C)
%
% Perform HOSVD (N-mode SVD)
%
% Inputs:
%     C: Data
%
% Outputs:
%     C: Core tensor
%     U: Mode matrices (cell array)
%
% Implemented by Minsik Lee (mlee.paper@gmail.com)
% Last update: 2014-03-19


nC = size(C); % Say, C = H, then nC = [120 100 9 500];

U = cell(1, numel(nC));                     % U = cell(1,4)
for i=1:numel(nC)                           % for i = 1:4
    C = reshape(C, nC(i), []);              % for i = 1 C is 120x45000, for i = 2 C is 100x540000, ...
    tU = fast_svd(C);                       % for i = 1 tU is 120x120, for i = 2 tU is 100x100, ...
    C = tU'*C;                              % same as earlier
    C = reshape(C', [nC(i+1:end) nC(1:i)]); % 100x9x500x120, 9x500x120x100, 500x120x100x9, 120x100x9x500
    U{i} = tU;                              % U{1}:120x120, U{2}:100x100, U{3}:9x9, U{4}:500x500
end

end

function U = fast_svd(X)
                                          % X is n_k' x n_k,
if diff(size(X)) < 0                      % if n_k' < n_k
    [Q, R] = qr(X, 0);                    % for i = 1, Q is 120 x 120, R is 120 x 45000
    [P, D] = eig(R*R');                   % for i = 1, P & D are 120x120
    [~, ind] = sort(diag(D), 'descend');  % 
    U = Q*P(:, ind);                      % U is 120x120
else                                      
    [U, D] = eig(X*X');                   % if n_k > n_k' 
    [~, ind] = sort(diag(D), 'descend');  % 
    U = U(:, ind);                        % U is 120x120
end

end
