function [xypairs] = createComplementaryPairs(xB, xI)
m = size(xB, 1);
yI = transpose(1:m);
n = size(xI, 1);
yB = transpose((m+1):(n+m));
X = [xI; xB];
Y = [yB; yI];
if(size(X, 1) == size(Y, 1))
    xypairs = [X Y];
else
    error('complementary variables X and Y should be of the same length')
end
end