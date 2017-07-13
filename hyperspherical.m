function X = hyperspherical(X)
% Convert to hyperspherical coordinates
%
% Implemented by Minsik Lee (mlee.paper@gmail.com)
% Last update: 2014-03-19


nd = size(X, 1);

tdiv = sqrt(sum(X.^2));
for i=1:nd-2
    X(i, :) = acos(min(max(X(i, :)./tdiv, -1), 1));
    tdiv = tdiv.*sin(X(i, :));
end
X(nd-1, :) = atan2(min(max(X(nd, :)./tdiv, -1), 1), min(max(X(nd-1, :)./tdiv, -1), 1));
X(nd-1, X(nd-1, :) < 0) = X(nd-1, X(nd-1, :) < 0) + 2*pi;

X = X(1:nd-1, :);
X(isnan(X)) = 0;

end