function [width, flag] = findWidth(loc_curr_peak, lcs_min, lcs_zeros)
%%Given the current peak location (loc_curr_peak) and the locations of all
 %the minimas and the zeros, find the width of the current peak

% Flag indicates whether there are any nearest minima/zeros or not
flag = 0;

% Find the nearest minima distance
if(numel(lcs_min))
    [~, ind] = min(abs(lcs_min - loc_curr_peak));
    nearest_min_dist = abs(loc_curr_peak - lcs_min(ind));
    width = nearest_min_dist;
    flag = 1;
end

% Find the nearest zero distance and width
if(numel(lcs_zeros))
    [~, ind] = min(abs(lcs_zeros - loc_curr_peak));
    nearest_zero_dist = abs(loc_curr_peak - lcs_zeros(ind));
    if(flag)
        width = min(nearest_min_dist, nearest_zero_dist);
    else
        width = nearest_zero_dist;   
    end
end

end
