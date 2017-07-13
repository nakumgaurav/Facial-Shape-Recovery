% Training script for TR algorithm.
%
% Ref: [1] Minsik Lee and Chong-Ho Choi,
% "Real-time Facial Shape Recovery From a Single Image With General, Unknown Lighting by Rank Relaxation,"
% Computer Vision and Image Understanding, vol. 120, pp. 59-69, Mar. 2014.
% [2] Minsik Lee,
% "Facial Shape Recovery from a Single Image with General, Unknown Lighting,"
% Ph.D. dissertation, Seoul National University, 2012.
%
% Authors: Minsik Lee (mlee.paper@gmail.com)
% Last update: 2014-03-19
% License: GPLv3

%
% Copyright (C) 2014 Minsik Lee
% This file is part of SIFR.
%
% SIFR is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 3 of the License, or
% (at your option) any later version.
%
% SIFR is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with SIFR.  If not, see <http://www.gnu.org/licenses/>.



% **IMPORTANT: Run 'preprocess.m' at the first time to preprocess training data.


clear; close all;


% parameters
source = 'cast'; % 4, 9, or 'cast'

if strcmp(source, 'cast')
    nI = [40 30 10 300];
    nD = [40 30 200];
    nQ = 200;
    nW = 200;
else
    nI = [40 30 source 50];
    nD = [40 30 100];
    nQ = 100;
    nW = 50;
end

nQ = min(nQ, prod(nI(1:2)));
nW = min([nW nI(end) nD(end)]);

load pre/basic;

% depth model
load pre/DTD;
[DC DU] = TensorTrim(DC, DU, nD);
[Ud S V] = svd(reshape(DC, [], nD(3)), 'econ');
Dp = S*V'*DU{3}';
Ud1 = DU{1};
Ud2 = DU{2};


% illumination model
switch source
    case 4
        load pre/H4TD;
    case 9
        load pre/H9TD;
    case 'cast'
        load pre/ITD;
end
[C U] = TensorTrim(C, U, nI);
C = reshape(C, [], prod(nI(3:4)));
[Ui S] = eig(C*C');
[~, ind] = sort(diag(S), 'descend');
Ui = Ui(:, ind(1:nQ));

Pv = pinv(Ui'*C);
Ip = U{4}';
Ui1 = U{1};
Ui2 = U{2};
clear C U;

Mi = mean(Ip, 2);
Ip = Ip - repmat(Mi, 1, size(Ip, 2));
nMi = norm(Mi)^2;


% CCA
Rii = Ip*Ip';
Rid = Ip*Dp';
Rdd = Dp*Dp';

[V S] = eig([zeros(nI(end)) Rid; Rid' zeros(nD(end))], [Rii zeros(nI(end), nD(end)); zeros(nD(end), nI(end)) Rdd]+eps*eye(nI(end)+nD(end)));
[~, ind] = sort((diag(S)'), 'descend');
W = V(1:nI(end), ind(1:nW))*sqrt(2);
Pc = Rid'*W*W';

Db = DM - Ud1*reshape(Ud*(Pc*Mi), nD(1:2))*Ud2';


save model/RR n_y n_x rpts nI nD Ui Ui1 Ui2 Pv Mi nMi Ud Ud1 Ud2 Pc Db;







