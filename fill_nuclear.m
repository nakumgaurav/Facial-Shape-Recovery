function Y = fill_nuclear(X, W, bias_ambiguity)
% function Y = fill_nuclear(X, W, bias_ambiguity)
%
% Fill missing entries by minimizing nuclear-norm cost
% (Minimize || Y ||_* subject to W.*(Y-X) = 0)
%
% Inputs:
%     X: Observation data    (n_r x n_c)
%     W: Logical flag matrix (n_r x n_c)
%     bias_ambiguity: Flag bit for bias ambiguity
%
% Outputs:
%     Y: Reconstructed data  (n_r x n_c)
%
% Author: Minsik Lee (mlee.paper@gmail.com)
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


if nargin < 3
    bias_ambiguity = false;
end


Xp = X;
Xp(~W) = 0;
if bias_ambiguity
    nW = 1./sum(W);
    nW(isnan(nW)) = 0;
    Xp = Xp - repmat(sum(Xp).*nW, size(X, 1), 1).*W;
end

mu = 1e1/norm(Xp(:));
rho = 1.2;

% Augmented Lagrangian method + proximal approximation
cnt = 0;
L = zeros(size(X));
Y = Xp;
cost = inf;
while cost > 1e-12

    temp = Y.*W;
    if bias_ambiguity
        temp = temp - repmat(sum(temp).*nW, size(X, 1), 1).*W;
    end
    Y = Y - temp + Xp - L;
    [U S V] = svd(Y, 'econ');
    s = max(diag(S)-1/mu, 0);
    Y = U*diag(s)*V';

    C = Y.*W - Xp;
    if bias_ambiguity
        C = C - repmat(sum(C).*nW, size(X, 1), 1).*W;
    end
    L = L+C;
    cost = sqrt(mse(C(W)));

    mu = mu*rho;
    L = L/rho;

    cnt = cnt + 1;
%     disp(['F' num2str(cnt) ' : ' num2str(cost) ' / ' num2str(sum(s)) ' / ' num2str(mu)]);
end

end

