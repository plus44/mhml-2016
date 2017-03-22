function [w_opt,emin] = fallPerceptron(x, y, n, itmax)
i=1;
j=1;
emin=1;
w=zeros(size(x,2),1);
%w = rand(size(x,2),1);
while(j<itmax)
    j=j+1;
    if i <= n
        if ~isequal(y(i), sign(x(i,:)*w))
            w = w + (y(i)*x(i,:))';        
        end
        i=i+1;
    else
        i=1;
    end
    e = 1/n * sum(sign(x*w)~=y);
    if e<emin
        w_opt = w;
        emin=e;
    end
end
end