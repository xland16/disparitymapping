function [] = printDispMap(x,y,m,E,dir,file)
Disp = zeros(63,200);

i = 1;
%From large disparity space, create 2D cut from given specs
while x + (200 - i) < m && i <= 200
    for d = 1:63
        Disp(64-d,i) = E(y,x,d);
    end
    i = i + 1;
    x = x + 1;
end

%Save to image
dImg = mat2gray(Disp);

home = cd(dir);
cd('Stereo');
imwrite(dImg, file);
cd(home);
end