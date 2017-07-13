function [polyFit, h, centers] = hist_smoothen_hist(y)

xlim([0 260]);
h = histogram(y,256);
edges = h.BinEdges; 
counts = h.Values/max(h.Values);
h = histogram('BinEdges', edges, 'BinCounts', counts); hold on; 
heights = h.Values; centers = zeros(h.NumBins,1);
for i = 1:h.NumBins, centers(i) = (h.BinEdges(i) + h.BinEdges(i+1))/2; end;
% ax = gca;
% ax.XTickLabel = [];
n = h.NumBins;
w = h.BinWidth;
t = linspace(h.BinEdges(1),h.BinEdges(n+1),n+1);
p = fix(n/2);
% fill(t([p p p+1 p+1]),[0 heights([p p]),0],'w')
% plot(centers([p p]),[0 heights(p)],'r:')
% h = text(centers(p)-.2,heights(p)/2,'   h');
% dep = -70;
% tL = text(t(p),dep,'L');
% tR = text(t(p+1),dep,'R');
%hold off

dt = diff(t);
Fvals = cumsum([0,heights.*dt]);

F = spline(t, [0, Fvals, 0]);

DF = fnder(F);  % computes its first derivative
% h.String = 'h(i)';
% tL.String = 't(i)';
% tR.String = 't(i+1)';
fnplt(DF, 'r', 2)
polyFit = fnplt(DF, 'r', 2);

ylims = ylim;
ylim([0,ylims(2)]);