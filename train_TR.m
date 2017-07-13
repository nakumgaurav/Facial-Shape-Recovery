% Training script for TR algorithm.
%
% Ref: [1] Minsik Lee and Chong-Ho Choi,
% "Fast Facial Shape Recovery From a Single Image With General, Unknown Lighting by Using Tensor Representation,"
% Pattern Recognition, vol. 44, no. 7, pp. 1487-1496, Jul. 2011.
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
source = 9; % 4, 9, or 'cast'
% the source variable is used to indicate which source images will be used
% if source = 3 => we are using raw surface normal vectors
% if source = 4 or 9 => we are using the spherical harmonics representation

if strcmp(source, 'cast')
    nI = [40 30 10 150];    % [n_y',  n_x',  n_l',  n_phi'] [ny, nx, ns, nphi] 
    nD = [40 30 250];          % [ny',  nx', nphi']   
    nQ = 400;                  % number of column vectors of Q = np
    nW = 100;                  % number of basis vectors used for CCA
    psig = 0.8;                % sigma in TR paper
else
    nI = [40 30 source 80];    % [n_y',  n_x',  n_l',  n_phi'] [ny, nx, ns, nphi] 
    nD = [40 30 100];         
    nQ = 200;                 % np = 200
    nW = 50;                  
    psig = 1;
end

nQ = min(nQ, prod(nI(1:2)));
nW = min([nW nI(end) nD(end)]);

load pre/basic;


% depth model
load pre/DTD;
[DC, DU] = TensorTrim(DC, DU, nD);    
[Ud, S, V] = svd(reshape(DC, [], nD(3)), 'econ');    % Economic decomposition in SVD removes extra rows or columns of zeros from S 
                                                     % and their corresponding column vectors from U
Dp = S*V'*DU{3}';               % DU{3} = Vphi     (Dp will be used to compute Pc(P in paper) later()
Ud1 = DU{1};                    % Ud1 = DU{1} = Vx
Ud2 = DU{2};                    % Ud2 = DU{2} = Vy

% illumination model
switch source
    case 4
        load pre/H4TDM;
    case 9
        load pre/H9TDM;
    case 'cast'
        load pre/ITDM;
end

[C, U] = TensorTrim(C, U, nI);      % C - Core Tensor of Eq . 2 (2011 paper) and U is a cell array containing 
                                    % the 4 mode matrices Uy, Ux, Ul, Up (Ux, Uy, Us, Uphi)
                                    % U:120x40, 100x30, 9x9, 500x80
C = reshape(C, [], prod(nI(3:4)));  % C is now a 1200 x 1500(720) matrix = Uc * Lambdac * Vc'
[Ui, S] = eig(C*C');                % Ui has the singular vectors of C, while S stores (the squares of) C's 
                                    % singular values
[~, ind] = sort(diag(S), 'descend');    %(Ui:1200x1200  S:1200x1200)
Ui = Ui(:, ind(1:nQ));              % Ui contains the singular vectors of C such that their corresponding e.values are in decreasing order
                                    % Ui = Uc;  Ui = 1200x200 
Pt = reshape(Ui'*C, [nQ nI(3:4)]);  % T_tilda: 200x10x150 (200x9x80)4 
temp = M;                           % M is F_bar (calculated in preprocess.m): 120x100x9        
for i=1:3
    temp = Nproduct(temp, U{i}', i); % U{3} = Us (2014)
end                                  % temp = F_bar x1 Uy x2 Ux x3 Us:40x30x9
Mt = Ui' * reshape(temp, [], nI(3)); % Mt is T_bar: 200x9
Ip = U{4}';
Ui1 = U{1};                         % Ui1 = U{1} = Uy
Ui2 = U{2};                         % Ui2 = U{2} = Ux
clear C U;


% CCA
Rii = Ip*Ip';
Rid = Ip*Dp';
Rdd = Dp*Dp';

[V, S] = eig([zeros(nI(end)) Rid; Rid' zeros(nD(end))], [Rii zeros(nI(end), nD(end)); zeros(nD(end), nI(end)) Rdd]+eps*eye(nI(end)+nD(end)));
[~, ind] = sort((diag(S)'), 'descend');
W = V(1:nI(end), ind(1:nW)) * sqrt(2);
Pc = Rid' * W * W';


% prior information
Rv = inv(Rii)*((size(Ip, 2)-1)*psig^2);


save model/TR n_y n_x rpts nI nD Ui Ui1 Ui2 Pt Mt Rv Ud Ud1 Ud2 Pc DM;

