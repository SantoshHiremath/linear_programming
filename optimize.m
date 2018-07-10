function [outputType, Dnew, xBnew, xInew] = optimize(D, xB, xI)
outputType = 0;
steps = 0;
while (outputType == 0)
    steps = steps + 1;
    [outputType Dnew xBnew xInew] = singlePivot(D, xB, xI);
    D = Dnew;
    xB = xBnew;
    xI = xInew;    
end
end