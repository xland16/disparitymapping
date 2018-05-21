function [E] = diffuse(m,n,E,lambda,beta)
%for each combination of x, y, and d...
for y = 1:n
    for x = 1:m
        for d = 1:63
            %Discrete formula from paper
            val = (1-lambda*(beta+4))*E(y,x,d)+lambda*(beta*E(y,x,d));
            
            %If valid, get values for diffusion window
            if x-2 >= 1
                val = val + lambda*E(y,x-2,d);
            end
            if x-1 >= 1
                val = val + lambda*E(y,x-1,d);
            end                    
            if x+1 <= m
                val = val + lambda*E(y,x+1,d);
            end
            if x+2 <= m
                val = val + lambda*E(y,x+2,d);
            end
            E(y,x,d) = val;
        end
    end
end
end