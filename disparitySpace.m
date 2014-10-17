function [] = disparitySpace(dir,lFile,rFile,NUM)

home = cd(dir);
refImg = imread(rFile);
IL = im2double(rgb2gray(imread(lFile)));
IR = im2double(rgb2gray(imread(rFile)));

%imwrite(imread(lFile),'im2.png');
%imwrite(imread(rFile),'im6.png');

myDir = cd(home);

[n m] = size(IR);

Px = zeros(NUM,1);
Px_l = zeros(NUM,1);
Px_h = zeros(NUM,1);
Py = zeros(NUM,1);

figure; imshow(refImg);

%Get points to create strip
for i = 1:NUM
    [Px(i),Py(i)] = getpts;
    Px_l(i) = uint16(Px(i));
    Px_h(i) = uint16(Px(i))+199;
end

for i = 1:NUM
    %Draw boxes around selected points
    for xi = Px_l(i)-1:Px_h(i)+1
        refImg(uint16(Py(i))-1,xi,1) = 0;
        refImg(uint16(Py(i))-1,xi,2) = 255;
        refImg(uint16(Py(i))-1,xi,3) = 0;
        refImg(uint16(Py(i))+1,xi,1) = 0;
        refImg(uint16(Py(i))+1,xi,2) = 255;
        refImg(uint16(Py(i))+1,xi,3) = 0;
    end
    
    refImg(uint16(Py(i)),Px_l(i)-1,1) = 0;
    refImg(uint16(Py(i)),Px_l(i)-1,2) = 255;
    refImg(uint16(Py(i)),Px_l(i)-1,3) = 0;
    refImg(uint16(Py(i)),Px_h(i)+1,1) = 0;
    refImg(uint16(Py(i)),Px_h(i)+1,2) = 255;
    refImg(uint16(Py(i)),Px_h(i)+1,3) = 0;

    Disp = NaN(63,200);
    
    d = 1;
    
    %Calculate difference value at disparities
    while Px_h(i)+d <= m && d <= 63
        index = 1;
        for x = Px_l(i):Px_h(i)
            Disp(64-d,index) = (IL(uint8(Py(i)),x+d)-IR(uint8(Py(i)),x))^2;
            index = index + 1;
        end
        d = d + 1;
    end
   
    %Normalize and save
    Dmax = max(max(Disp))
    Disp = Disp/Dmax;
    dImg = mat2gray(Disp);
    
    cd(myDir);
    cd('DispSpace');
    imwrite(dImg, [dir '-' num2str(i) '-' num2str(Px_l(i)) '-' num2str(Py(i)) '.png']);
    cd(home);
end

cd(myDir);
cd('DispSpace');
imwrite(refImg, [dir '-selection.png']);
cd(home);

end