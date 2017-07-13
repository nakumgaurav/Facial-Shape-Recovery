function faulty = findFaulty(Fits)
%load('MFs.mat');
x = (0:1:255)';
k = 1;
faulty = cell(10,1);


for i = 1:130
    for j = 1:120
        if(numel(Fits{i,j,1}))
        f_l = Fits{i,j,1};
        f_u = Fits{i,j,2};
        y_l = f_l(x);
        y_u = f_u(x);
        if(sum(y_l > y_u))
            faulty{k} = [i,j];
            k = k + 1;
        end
        end
    end
end

%{
%p0
for i = 1:15
    for j = 1:13
        f_l = Fits_partial_0{i,j,1}; 
        f_u = Fits_partial_0{i,j,2};
        y_l = f_l(x); 
        y_u = f_u(x);
        if(sum(y_l > y_u))
            faulty{k} = [i,j];
            k = k + 1;
        end    
    end
end

%p1
    for j = 14:120
        f_l = Fits_partial_1{1,j,1}; 
        f_u = Fits_partial_1{1,j,2};
        y_l = f_l(x); 
        y_u = f_u(x);
        if(sum(y_l > y_u))
            faulty{k} = [i,j];
            k = k + 1;
        end    
    end

%p2
for i = 16:19
    for j = 1:13
        f_l = Fits_partial_2{i,j,1}; 
        f_u = Fits_partial_2{i,j,2};
        y_l = f_l(x); 
        y_u = f_u(x);
        if(sum(y_l > y_u))
            faulty{k} = [i,j];
            k = k + 1;
        end    
    end
end
 
%p3
for i = 20:130
    for j = 1:13
        f_l = Fits_partial_3{i,j,1}; 
        f_u = Fits_partial_3{i,j,2};
        y_l = f_l(x); 
        y_u = f_u(x);
        if(sum(y_l > y_u))
            faulty{k} = [i,j];
            k = k + 1;
        end    
    end
end

%p4
for i = 2:19
    for j = 14:120
        f_l = Fits_partial_4{i,j,1}; 
        f_u = Fits_partial_4{i,j,2};
        y_l = f_l(x); 
        y_u = f_u(x);
        if(sum(y_l > y_u))
            faulty{k} = [i,j];
            k = k + 1;
        end    
    end
end

%p5
for i = 20:50
    for j = 14:120
        f_l = Fits_partial_5{i,j,1}; 
        f_u = Fits_partial_5{i,j,2};
        y_l = f_l(x); 
        y_u = f_u(x);
        if(sum(y_l > y_u))
            faulty{k} = [i,j];
            k = k + 1;
        end    
    end
end

%p6
for i = 90:130
    for j = 14:120
        f_l = Fits_partial_6{i,j,1}; 
        f_u = Fits_partial_6{i,j,2};
        y_l = f_l(x); 
        y_u = f_u(x);
        if(sum(y_l > y_u))
            faulty{k} = [i,j];
            k = k + 1;
        end    
    end
end

%p7
for i = 51:89
    for j = 14:120
        f_l = Fits_partial_7{i,j,1}; 
        f_u = Fits_partial_7{i,j,2};
        y_l = f_l(x); 
        y_u = f_u(x);
        if(sum(y_l > y_u))
            faulty{k} = [i,j];
            k = k + 1;
        end    
    end
end
%}

%{
%p8
for i = 131:140
    for j = 1:120
        f_l = Fits_partial_8{i,j,1}; 
        f_u = Fits_partial_8{i,j,2};
        y_l = f_l(x); 
        y_u = f_u(x);
        if(sum(y_l > y_u))
            faulty{k} = [i,j];
            k = k + 1;
        end    
    end
end
%}