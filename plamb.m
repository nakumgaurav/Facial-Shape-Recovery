function im = plamb(depth, sn, s, penum, alb)
% function im = plamb(depth, sn, s, penum, alb)
%
% Render image with cast shadow.
%
% Inputs:
%     depth: Depth map          (n_y x n_x)
%     sn: Surface normal map    (n_y x n_x x 3)
%     s: Light vector           (3 x 1)
%     penum: Penumbra parameter
%     alb: albedo map           (n_y x n_x)
%
% Outputs:
%     im: Rendered image        (n_y x n_x)
%
% This is a custom implementation of the depth-map-based rendering scheme in
% Sung-Ho Lee and Chang-Hun Kim,
% "Real-time Soft Shadowing of Dynamic Height Map Using a Shadow Height Map,"
% Journal of the Korea Computer Graphics Society, vol. 14, no. 1, pp. 11-16, March 2008.
%
% A skyline algorithm has been added by Minsik Lee for more accurate calculation
%
% Implemented by Minsik Lee (mlee.paper@gmail.com)
% Last update: 2014-03-19


nocast = sn2img(sn, s);

if all(s(1:2) == 0)
    im = nocast;
    return;
end

dmax = 1e10;
depth(depth == inf) = dmax;
depth(depth == -inf) = -dmax;

td = depth;
ts = s;
if ts(1) > 0
    td = fliplr(td);
end
if ts(2) > 0
    td = flipud(td);
end
[ts(1:2) ind] = sort(abs(ts(1:2)), 'descend');
ts(3) = -ts(3);
ts = ts/ts(1);
if ind(1) == 2
    td = td';
end

if ts(2) == 0
    for i=2:size(td, 2)
        td(:, i) = max(td(:, i-1)+ts(3), td(:, i));
    end
else
    % original
%     tp = 1:size(td, 1);
%     tn = 1:size(td, 1);
%     for i=2:size(td, 2)
%         td(2:end, i) = max(conv(td(:, i-1), [ts(2) 1-ts(2)], 'valid')+ts(3), td(2:end, i));
%     end

    % skyline
    tp = 1:size(td, 1);
    tn = 1:size(td, 1);
    tt = td(:, 1);
    for i=2:size(td, 2)
        [tp tt td(:, i)] = skyline(tn, td(:, i), tp+ts(2), tt+ts(3));
    end
end

if abs(s(1)) < abs(s(2))
    td = td';
end
if s(1) > 0
    td = fliplr(td);
end
if s(2) > 0
    td = flipud(td);
end

im = nocast;
if nargin < 4 || penum == 0
    im(td > depth) = 0;
else
    soft = (td-depth)/penum;
    soft(soft > 1) = 1;
    im = im.*(1-soft);
end

if nargin > 4
    im = im.*alb;
end
    
end

function [x y d1 d2] = skyline(x1, y1, x2, y2)
% skyline algorithm

n1 = numel(x1);
n2 = numel(x2);
d1 = y1;
d2 = y2;

if n1 == 0
    x = x2; y = y2;
    return;
end
if n2 == 0
    x = x1; y = y1;
    return;
end
if n1 == 1
    ind = x2 < x1;
    c2 = sum(ind);
    newy = (x1-x2(c2))*(y2(c2+1)-y2(c2))/(x2(c2+1)-x2(c2))+y2(c2);
    if newy < y1
        x = [x2(ind); x1; x2(~ind)];
        y = [y2(ind); y1; y2(~ind)];
    else
        x = x2; y = y2;
        d1 = newy;
    end
    return;
end
if n2 == 1
    ind = x1 < x2;
    c1 = sum(ind);
    newy = (x2-x1(c1))*(y1(c1+1)-y1(c1))/(x1(c1+1)-x1(c1))+y1(c1);
    if newy < y2
        x = [x1(ind); x2; x1(~ind)];
        y = [y1(ind); y2; y1(~ind)];
    else
        x = x1; y = y1;
        d2 = newy;
    end
    return;
end
x = zeros(n1+n2, 1);
y = zeros(n1+n2, 1);

if x1(1) < x2(1)
    ind = x1 < x2(1);
    x(ind) = x1(ind); y(ind) = y1(ind);
    c1 = sum(ind); c2 = 1; tc = c1+1;
    newy = (x2(c2)-x1(c1))*(y1(c1+1)-y1(c1))/(x1(c1+1)-x1(c1))+y1(c1);
    if newy < y2(c2)
        x(tc) = x2(c2); y(tc) = y2(c2);
        tc = tc+1;
        sel = 2;
    else
        d2(c2) = newy;
        sel = 1;
    end
else
    ind = x2 < x1(1);
    x(ind) = x2(ind); y(ind) = y2(ind);
    c2 = sum(ind); c1 = 1; tc = c2+1;
    newy = (x1(c1)-x2(c2))*(y2(c2+1)-y2(c2))/(x2(c2+1)-x2(c2))+y2(c2);
    if newy < y1(c1)
        x(tc) = x1(c1); y(tc) = y1(c1);
        tc = tc+1;
        sel = 1;
    else
        d1(c1) = newy;
        sel = 2;
    end
end

while c1 < n1 && c2 < n2
    if x1(c1+1) < x2(c2+1)
        c1=c1+1;
        newy = (x1(c1)-x2(c2))*(y2(c2+1)-y2(c2))/(x2(c2+1)-x2(c2))+y2(c2);
        if newy < y1(c1)
            if sel == 2
                tt = ((x1(c1)-x2(c2+1))*(y2(c2)-y2(c2+1))-(x2(c2)-x2(c2+1))*(y1(c1)-y2(c2+1)))/((x1(c1)-x1(c1-1))*(y2(c2)-y2(c2+1))-(x2(c2)-x2(c2+1))*(y1(c1)-y1(c1-1)));
                x(tc) = x1(c1-1)*tt+x1(c1)*(1-tt); y(tc) = y1(c1-1)*tt+y1(c1)*(1-tt);
                x(tc+1) = x1(c1); y(tc+1) = y1(c1);
                tc = tc+2;
                sel = 1;
            else
                x(tc) = x1(c1); y(tc) = y1(c1);
                tc = tc+1;
            end
        else
            if sel == 1
                tt = ((x1(c1)-x2(c2+1))*(y2(c2)-y2(c2+1))-(x2(c2)-x2(c2+1))*(y1(c1)-y2(c2+1)))/((x1(c1)-x1(c1-1))*(y2(c2)-y2(c2+1))-(x2(c2)-x2(c2+1))*(y1(c1)-y1(c1-1)));
                x(tc) = x1(c1-1)*tt+x1(c1)*(1-tt); y(tc) = y1(c1-1)*tt+y1(c1)*(1-tt);
                tc = tc+1;
                sel = 2;
            end
            d1(c1) = newy;
        end
    else
        c2=c2+1;
        newy = (x2(c2)-x1(c1))*(y1(c1+1)-y1(c1))/(x1(c1+1)-x1(c1))+y1(c1);
        if newy < y2(c2)
            if sel == 1
                tt = ((x1(c1+1)-x2(c2))*(y2(c2-1)-y2(c2))-(x2(c2-1)-x2(c2))*(y1(c1+1)-y2(c2)))/((x1(c1+1)-x1(c1))*(y2(c2-1)-y2(c2))-(x2(c2-1)-x2(c2))*(y1(c1+1)-y1(c1)));
                x(tc) = x1(c1)*tt+x1(c1+1)*(1-tt); y(tc) = y1(c1)*tt+y1(c1+1)*(1-tt);
                x(tc+1) = x2(c2); y(tc+1) = y2(c2);
                tc = tc+2;
                sel = 2;
            else
                x(tc) = x2(c2); y(tc) = y2(c2);
                tc = tc+1;
            end
        else
            if sel == 2
                tt = ((x1(c1+1)-x2(c2))*(y2(c2-1)-y2(c2))-(x2(c2-1)-x2(c2))*(y1(c1+1)-y2(c2)))/((x1(c1+1)-x1(c1))*(y2(c2-1)-y2(c2))-(x2(c2-1)-x2(c2))*(y1(c1+1)-y1(c1)));
                x(tc) = x1(c1)*tt+x1(c1+1)*(1-tt); y(tc) = y1(c1)*tt+y1(c1+1)*(1-tt);
                tc = tc+1;
                sel = 1;
            end
            d2(c2) = newy;
        end
    end
end

if c1 == n1
    c2=c2+1;
    x(tc:tc+n2-c2) = x2(c2:end);
    y(tc:tc+n2-c2) = y2(c2:end);
    tc = tc+n2-c2;
else
    c1=c1+1;
    x(tc:tc+n1-c1) = x1(c1:end);
    y(tc:tc+n1-c1) = y1(c1:end);
    tc = tc+n1-c1;
end
x = x(1:tc);
y = y(1:tc);
end

