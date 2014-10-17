function [C] = getWinMargin(m,n,E)
C = zeros(n,m);
%For each point x,y..
for y = 1:n
    for x = 1:m
        min = Inf;
        secMin = Inf;
        sum = 0;
        %Find 2 min values among all d valeus
        for d = 1:63
            sum = sum + E(y,x,d);
            if E(y,x,d) < secMin
                secMin = E(y,x,d);
                if secMin < min
                    temp = secMin;
                    secMin = min;
                    min = temp;
                end
            end
        end
        %Store the normalized winner margin
        C(y,x) = (secMin - min)/sum;
    end
end
end