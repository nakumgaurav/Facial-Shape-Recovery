function [C, U] = TensorTrim(C, U, N)
% Truncate HOSVD result
%
% Common:
%     C: Core tensor
%     U: Mode matrices (cell array)
%
% Inputs:
%     N: Mode dimensions after truncation
%
% Implemented by Minsik Lee (mlee.paper@gmail.com)
% Last update: 2014-03-19


ind = cell(1, numel(N));
for i=1:numel(N)
   i
    ind{i} = 1:N(i);
    U{i} = U{i}(:,ind{i});
end
C = C(ind{:}); % C(ind{:}) is same as C([1 ... 40], [1 ... 30], [1 ... 100]). What this will do is assign each C(i,j,k) to C
               % where i is taken from ind{1} = [1 ... 40], j is taken from
               % ind{2} = [1 ... 30] and k is taken from ind{3} = [1 ... 100]
               % It effectively truncates C to the dimensions 40x30x100
end
