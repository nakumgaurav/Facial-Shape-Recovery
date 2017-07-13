function [u, secondary] = secondaryMemb(z_l,~,z_u)
%% Construction of a secondary membership function (vertical slice)


% Height
a = 1;
% Mean
b = (z_l + z_u)/2;
% SD
c = (z_u - z_l)/4;


u = linspace(z_l,z_u,100);
secondary = a*exp(-(u-b).^2/(c.^2));
%{
f = fit(u',secondary','gauss1');
f.a1 = a;
f.b1= b;
%}

%{
u = linspace(0,1,200);
secondary = zeros(1,200);

ind1a = find(u>=z_l); ind1b =  find(u<=z_u); ind1 = intersect(ind1a,ind1b);
ind2a = find(u<z_l); ind2b =  find(u>z_u); ind2 = union(ind2a,ind2b);
secondary(ind1) = a*exp(-((u(ind1)-b)/c).^2);
secondary(ind2) = 0;
%}
