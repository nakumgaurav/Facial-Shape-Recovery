function fr = findFreq(I)

fr = zeros(256,1);
for k = 1:256
    fr(k) = numel(find(squeeze(I) == k-1));
end