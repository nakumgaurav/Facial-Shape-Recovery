function [J,grad] = computeCost(params,x,y)
%%a = [a1,...,an] b = [b1,...,bn] c = [c1,...,cn]
%
m = numel(x);
n = length(params)/3;
%n = length(params)/2;
a = params(1:n); b = params(n+1:2*n); c = params(2*n+1:3*n);
%c = params(1:n); b = params(n+1:2*n);
J = 0;
for i = 1:m
    temp = 0;
    for j = 1:n
        temp = temp + a(j)*exp(-((x(i) - b(j))/c(j))^2);
    end
    J = J + ((temp - y(i)))^2;
end
J = J/(2*m);

  grad = zeros(3*n,1);
  %grad = zeros(2*n,1);
  %grad = zeros(n,1);
for k = 1:n
    for i = 1:m
        temp = 0;
        for j = 1:n
            temp = temp + exp(-((x(i) - b(j))/c(j))^2);
        end
        grad(k) = grad(k) + (temp - y(i)) * exp(-((x(i) - b(k))/c(k))^2);
    end
    grad(k) = grad(k)/m;
end

for k = n+1:2*n
    for i = 1:m
        temp = 0;
        for j = 1:n
            temp = temp + exp(-((x(i) - b(j))/c(j))^2);
        end
        grad(k) = grad(k) + (temp - y(i)) * a(k-n) * exp(-((x(i) - b(k-n))/c(k-n))^2) * 2 *(x(i) - b(k-n))/c(k-n)^2;
    end
    grad(k) = grad(k)/m;
end
  
for k = 2*n+1:3*n
    for i = 1:m
        temp = 0;
        for j = 1:n
            temp = temp + exp(-((x(i) - b(j))/c(j))^2);
        end
        grad(k) = grad(k) + (temp - y(i)) * a(k-2*n) * exp(-((x(i) - b(k-2*n))/c(k-2*n))^2) * 2 *(x(i) - b(k-2*n))^2/c(k-2*n)^3;
    end
    grad(k) = grad(k)/m;
end

%{  
for k = 1:n
    for i = 1:m
        temp = 0;
        for j = 1:n
            temp = temp + exp(-((x(i) - b(j))/c(j))^2);
        end
        grad(k) = grad(k) + (temp - y(i)) * a(k) * exp(-((x(i) - b(k))/c(k))^2) * 2 *(x(i) - b(k))^2/c(k)^3;
    end
    grad(k) = grad(k)/m;
end

for k = n+1:2*n
    for i = 1:m
        temp = 0;
        for j = 1:n
            temp = temp + exp(-((x(i) - b(j))/c(j))^2);
        end
        grad(k) = grad(k) + (temp - y(i)) * a(k-n) * exp(-((x(i) - b(k-n))/c(k-n))^2) * 2 *(x(i) - b(k-n))/c(k-n)^2;
    end
    grad(k) = grad(k)/m;
end
%}

% grad = [grad(1:n) grad(n+1:2*n) grad(2*n+1:3*n)];

end