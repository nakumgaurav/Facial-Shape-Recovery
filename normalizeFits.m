function [f_l, f_u] = normalizeFits(f_lower, f_upper)
%% Normalize and Scale the fits 
x = (0:1:255)';
y_upper = f_upper(x);
y_lower = f_lower(x);
a = max(y_upper);
y_upper = y_upper/a;
scale = 1/a;
y_lower = y_lower * scale;
f_l = fit(x,y_lower,'gauss1');
f_u = fit(x,y_upper,'gauss1');
