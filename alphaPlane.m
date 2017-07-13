function [sec, lmf, umf] = alphaPlane(i,j,alpha)
%%Returns the alpha-plane of the (i,j)th pixel defined by lmf-umf or sec

% Construct the secondary membership functions
[U, Z] = secondaryFuncs(i,j);

% Construct alpha-cuts for secondary membership function at each pixel intensity x
sec = cell(256,1);
lmf = zeros(256,1);
umf = zeros(256,1);

if(alpha == 1)
    for k = 1:256
        u = U(k,:);
        z = Z(k,:);
        [~, ind] = max(z);
        sec{k} = u(ind);
        lmf(k) = sec{k};
        umf(k) = sec{k};
    end
return; 
end

for k = 1:256
    u = U(k,:);
    z = Z(k,:);
    sec{k} = u(z >= alpha);
    lmf(k) = min(sec{k});
    umf(k) = max(sec{k});
end

end