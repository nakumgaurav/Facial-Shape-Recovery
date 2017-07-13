function f = fitData_improved(x, y, peaks_max, peaks_min)
%%fitData(x,y,peak_lcs) fits a multi-Gaussian curve to the data specified
%%by the data points (x,y). peak_lcs stores the x-coordiantes of the
%%locations of the prominent peaks. The peak of each component Gaussian 
%%curve will be centered around the values specified by peak_lcs

pks_max = peaks_max{1}; 
lcs_max = peaks_max{2}; 
% w_max = peaks_max{3}; p_max = peaks_max{4};

%pks_min = peaks_min{1}; 
lcs_min = peaks_min{2}; 
%w_min = peaks_min{3}; p_min = peaks_min{4};                                                

% Locate the zeros of the PF
lcs_zeros = x(y==0);

% Determine the number of peaks = number of terms in multi-Gaussian fit
no_peaks = numel(lcs_max);

switch(no_peaks)
    case 1
        
            f = fit(x, y, 'gauss1');
            % Adjust Gaussian mean
            f.b1 = lcs_max(1);
        
            % Adjust Gaussian variance
            [width, flag] = findWidth(lcs_max(1), lcs_min, lcs_zeros);
            if(flag)
                f.c1 = width;
            end
            
    case 2
        f = fit(x, y, 'gauss2');
        f.b1 = lcs_max(1); f.b2 = lcs_max(2);
        
        [width, flag] = findWidth(lcs_max(1), lcs_min, lcs_zeros);
        if(flag)
            f.c1 = width;
        end
        [width, flag] = findWidth(lcs_max(2), lcs_min, lcs_zeros);
        if(flag)
            f.c2 = width;
        end
        
        
    case 3
        f = fit(x, y, 'gauss3');
        f.b1 = lcs_max(1); f.b2 = lcs_max(2); f.b3 = lcs_max(3);
        
        [width, flag] = findWidth(lcs_max(1), lcs_min, lcs_zeros);
        if(flag)
            f.c1 = width;
        end
        [width, flag] = findWidth(lcs_max(2), lcs_min, lcs_zeros);
        if(flag)
            f.c2 = width;
        end
        [width, flag] = findWidth(lcs_max(3), lcs_min, lcs_zeros);
        if(flag)
            f.c3 = width;
        end
        
        
    case 4
        f = fit(x, y, 'gauss4');
        
        f.b1 = lcs_max(1); f.b2 = lcs_max(2); f.b3 = lcs_max(3); 
                                                f.b4 = lcs_max(4);
         
        [width, flag] = findWidth(lcs_max(1), lcs_min, lcs_zeros);
        if(flag)
            f.c1 = width;
        end
        [width, flag] = findWidth(lcs_max(2), lcs_min, lcs_zeros);
        if(flag)
            f.c2 = width;
        end
        [width, flag] = findWidth(lcs_max(3), lcs_min, lcs_zeros);
        if(flag)
            f.c3 = width;
        end
        [width, flag] = findWidth(lcs_max(4), lcs_min, lcs_zeros);
        if(flag)
            f.c4 = width;
        end    
        
        
    case 5
        f = fit(x, y, 'gauss5');
        f.b1 = lcs_max(1); f.b2 = lcs_max(2); f.b3 = lcs_max(3); 
                             f.b4 = lcs_max(4); f.b5 = lcs_max(5); 
        
        [width, flag] = findWidth(lcs_max(1), lcs_min, lcs_zeros);
        if(flag)
            f.c1 = width;
        end
        [width, flag] = findWidth(lcs_max(2), lcs_min, lcs_zeros);
        if(flag)
            f.c2 = width;
        end
        [width, flag] = findWidth(lcs_max(3), lcs_min, lcs_zeros);
        if(flag)
            f.c3 = width;
        end
        [width, flag] = findWidth(lcs_max(4), lcs_min, lcs_zeros);
        if(flag)
            f.c4 = width;
        end
        [width, flag] = findWidth(lcs_max(5), lcs_min, lcs_zeros);
        if(flag)
            f.c5 = width;
        end   
        
        
    otherwise
        % Reduce the number of peaks to 5 by eliminating peaks
        while(numel(lcs_max) == 5)
            % find the two closest peaks ind and ind+1
            [~, ind] = min(diff(lcs_max));
            % find the higher of the two peaks
            v = [y(lcs_max(ind)) y(lcs_max(ind+1))];
            [~, max_ind] = max(v);
            % Replace them by their maximum (one which has greater height)
            if(max_ind == 1)
                lcs_max(ind+1) = [];
            else
                lcs_max(ind) = [];
            end
        end
        % then fit gauss5
        if(numel(lcs_max) == 5)
            f = fit(x, y, 'gauss5');
            f.b1 = lcs_max(1); f.b2 = lcs_max(2); f.b3 = lcs_max(3); 
                               f.b4 = lcs_max(4); f.b5 = lcs_max(5); 

        end
end

% Match the peaks of the original and fitted data by modifying the 
% parameters f.ai of the asymmetric Gaussians (heights) 
f = matchPeaks(f,pks_max);


    