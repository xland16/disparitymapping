function [] = stereoSSD(dir,lFile,rFile,nSize,setting,Px,Py)

home = cd(dir);
IL = im2double(rgb2gray(imread(lFile)));
IR = im2double(rgb2gray(imread(rFile)));
myDir = cd(home);

[n m] = size(IL);

D = zeros(n,m);
Disp = Inf(n,m);
E = Inf(n,m,63);

[PT_NUM] = size(Px);

sum = 0;
for d = 1:63
    for y = 1:n
        for x = 1:m
            [x_l x_h y_l y_h] = getNDim(x,y,m,n,nSize);
            yi = y;
            %If disparity brings you past border of image, ignore
            if x_h+d > m
                sum = Inf;
            else
                %Calculate the SSD for each pixel and disparity value for
                %the window size
                if x == 1
                    sum = 0;
                    for xi = x_l:x_h
                        %for yi = y_l:y_h
                            sum = sum + (IL(yi,xi+d)-IR(yi,xi))^2;
                        %end
                    end
                else
                   if p_l < x_l;
                       %for yi = y_l:y_h
                           sum = sum - (IL(yi,p_l+d)-IR(yi,p_l))^2;
                       %end
                    end
                    if p_h < x_h
                        %for yi = y_l:y_h
                            sum = sum + (IL(yi,x_h+d)-IR(yi,x_h))^2;
                        %end
                    end
                end
            end
           
            E(y,x,d) = sum;
            
            p_h = x_h;
            p_l = x_l;
        end
    end
end

numIter = 10;
beta = .5;
lambda = .15;

Cm  = zeros(n,m);
Cmi = zeros(n,m);
Ei  = Inf(n,m,63);

%Perform diffusion
if setting == 1 
    for num = 1:numIter
        E = diffuse(m,n,E,lambda,beta);
        
        for i = 1:PT_NUM
            printDispMap(Px(i),Py(i),m,E,dir,[dir '-Diffuse-Seg' num2str(i) '-N' num2str(nSize)  '-' num2str(num) '.png']);
        end
        
        printDispImg(m,n,E,dir,[dir '-Diffuse-N' num2str(nSize) '-' num2str(num) '.png']);
    end
%Perform selective diffusion
elseif setting == 2
    for num = 1:numIter
        %Store over previous E values
        for y = 1:n
            for x = 1:m
                for d = 1:63
                    Ei(y,x,d) = E(y,x,d);
                end
            end
        end
    
        Cm  = getWinMargin(m,n,E);
        
        X_vals = zeros(200,1);
        C_vals = zeros(200,1);
        
        %Plot certainties before diffusion
        for i = 1:200
            X_vals(i) = Px(1)+i-1;
        end
        
        for i = 1:200
            C_vals(i) = Cm(Px(1)+i-1,Py(1));
        end
        
        figure; plot(X_vals,C_vals);
        
        E = diffuse(m,n,E,lambda,beta);
        Cmi = getWinMargin(m,n,E);

        %Plot certainties after diffusion
        for i = 1:200
            X_vals(i) = Px(1)+i-1;
        end
        
        for i = 1:200
            C_vals(i) = Cm(Px(1)+i-1,Py(1));
        end
        
        figure; plot(X_vals,C_vals);
        
        %If previous certainty is greater than new, revert
        for y = 1:n
            for x = 1:m
                if Cm(y,x) > Cmi(y,x)
                    for d = 1:63
                        E(y,x,d) = Ei(y,x,d);
                    end
                end
            end
        end

        %Save updated files
        for i = 1:PT_NUM
            printDispMap(Px(i),Py(i),m,E,dir,[dir '-Winner-Seg' num2str(i) '-N' num2str(nSize)  '-' num2str(num) '.png']);
        end
        printDispImg(m,n,E,dir,[dir '-Winner-N' num2str(nSize) '-' num2str(num) '.png']);
    end
else
    %Preform normal SSD technique.  Already done so save files.
    for i = 1:PT_NUM
        printDispMap(Px(i),Py(i),m,E,dir,[dir '-SSD-Seg' num2str(i) '-N' num2str(nSize) '.png']);
    end
    printDispImg(m,n,E,dir,[dir '-SSD-N' num2str(nSize) '.png']);
end
end