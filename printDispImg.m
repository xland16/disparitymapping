function[] = printDispImg(m,n,E,dir,file);
Disp = Inf(n,m);
%For each point
for y = 1:n
    for x = 1:m
        minVal = Inf;
        for d = 1:63
            %Find the disparity with minimum SSD
            if E(y,x,d) < minVal
                minVal = E(y,x,d);
                minDisp = d;
            end
        end
        %And save that value
        Disp(y,x) = minDisp;
    end
end

%Normalize and save
Dmax = max(max(Disp));
Disp = Disp/Dmax;
dispImg = mat2gray(Disp);
home = cd(dir);
cd('Stereo');
imwrite(dispImg, file);
cd(home);
end