% Training script for NIM algorithm.
%
% Ref: Minsik Lee and Chong-Ho Choi,
% "A Robust Real-Time Algorithm for Facial Shape Recovery From a Single Image Containing Cast Shadow Under General, Unknown Lighting,"
% Pattern Recognition, vol. 46, no. 1, pp. 38-44, Jan. 2013.
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
nI = [40 30 220];
nD = [30 30 200];
nQ = 200;
nW = 170;

nQ = min(nQ, nI(end));
nf = nQ-1;
nW = min([nW nf nD(end)]);

load pre/basic;

% depth model
load pre/DTD;
[DC DU] = TensorTrim(DC, DU, nD);
[Ud S V] = svd(reshape(DC, [], nD(3)), 'econ');
Dp = S*V'*DU{3}';
Ud1 = DU{1};
Ud2 = DU{2};


% illumination model
load pre/ITD;

[C U] = TensorTrim(C, U, [nI(1:2) size(C, 3) size(C, 4)]);
C = reshape(C, prod(nI(1:2)), []);
[Ui S] = eig(C*C');
[~, ind] = sort(diag(S), 'descend');
Ui = Ui(:, ind(1:nI(3)));
Ui1 = U{1};
Ui2 = U{2};
clear C U;

load pre/I;
ns = size(I, 3);
np = size(I, 4);

Pz = reshape(Nproduct(Nproduct(reshape(Ui, nI), Ui1, 1), Ui2, 2), [], nI(end));
Z = Pz'*reshape(I, n_y*n_x, []);
Mz = squeeze(mean(reshape(Z, [], ns, np), 2));
Rzz = Z*Z'/ns;
clear I;

% Rayleigh quotient
[V S] = eig(Mz*Mz', Rzz-Mz*Mz');
[~, ind] = sort(diag(S), 'descend');
V = V(:, ind(1:nQ));
Ui = Ui*V;
Z = V'*Z;

% Hyperspherical mapping
Z = hyperspherical(Z);
Mz = squeeze(mean(reshape(Z, nf, ns, np), 2));
Rzz = Z*Z'/ns;
clear Z;


Mx = mean(Mz, 2);
Mz = Mz - repmat(Mx, 1, np);
Rzz = Rzz - np*(Mx*Mx');
Rzd = Mz*Dp';
Rdd = Dp*Dp';


% CCA
[V S] = eig([zeros(nf) Rzd; Rzd' zeros(nD(end))], [Rzz zeros(nf, nD(end)); zeros(nD(end), nf) Rdd]+eps*eye(nf+nD(end)));
[~, ind] = sort(diag(S), 'descend');

W = V(1:nf, ind(1:min(nW)))*sqrt(2);

psig = 6e-1;
Pc = Rzd'*W*W'/(1+psig^2);
Db = DM - Ud1*reshape(Ud*(Pc*Mx), nD(1:2))*Ud2';


save model/NIM n_y n_x rpts nD Ui Ui1 Ui2 Ud Ud1 Ud2 Pc Db;






