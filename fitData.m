function f = fitData(x, y, peaks)
%%fitData(x,y,peak_lcs) fits a multi-Gaussian curve to the data specified
%%by the data points (x,y). peak_lcs stores the x-coordiantes of the
%%locations of the prominent peaks. The peak of each component Gaussian 
%%curve will be centered around the values specified by peak_lcs

pks = peaks{1}; peak_lcs = peaks{2}; w = peaks{3}; p = peaks{4};

% Determine the number of peaks = number of terms in multi-Gaussian fit
no_peaks = numel(peak_lcs);

switch(no_peaks)
    case 1
        f = fit(x, y, 'gauss1');
        f.b1 = peak_lcs(1);
    case 2
        f = fit(x, y, 'gauss2');
        f.b1 = peak_lcs(1); f.b2 = peak_lcs(2);
        
    case 3
        f = fit(x, y, 'gauss3');
        f.b1 = peak_lcs(1); f.b2 = peak_lcs(2); f.b3 = peak_lcs(3);
        
        
    case 4
        f = fit(x, y, 'gauss4');
        f.b1 = peak_lcs(1); f.b2 = peak_lcs(2); f.b3 = peak_lcs(3); 
                                                f.b4 = peak_lcs(4);
        
        
    case 5
        f = fit(x, y, 'gauss5');
         f.b1 = peak_lcs(1); f.b2 = peak_lcs(2); f.b3 = peak_lcs(3); 
                             f.b4 = peak_lcs(4); f.b5 = peak_lcs(5); 
    otherwise
        % Reduce the number of peaks to 5 by eliminating peaks
        while(numel(peak_lcs) == 5)
            % find the two closest peaks ind and ind+1
            [~, ind] = min(diff(peak_lcs));
            % find the higher of the two peaks
            v = [y(peak_lcs(ind)) y(peak_lcs(ind+1))];
            [~, max_ind] = max(v);
            % Replace them by their maximum (one which has greater height)
            if(max_ind == 1)
                peak_lcs(ind+1) = [];
            else
                peak_lcs(ind) = [];
            end
        end
        % then fit gauss5
        if(numel(peak_lcs) == 5)
            f = fit(x, y, 'gauss5');
            f.b1 = peak_lcs(1); f.b2 = peak_lcs(2); f.b3 = peak_lcs(3); 
                                f.b4 = peak_lcs(4); f.b5 = peak_lcs(5); 

        end
end

f = matchPeaks(f,pks);

% plot the fitting curve f on the data
figure;
plot(y); 
hold on;
plot(f,x,y);
legend('Original Data', 'Fitted Data');
xlabel('x'); 
ylabel('u');
title('Fitting Curve'); 
hold off;