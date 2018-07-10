function [outputType, D_star, xB_star, xI_star] = lpSolve(D, xB, xI)
% check for feasiblity:
% feasible: all elements of b are non-negative
% not feasible: one or more elements of b is negative
b = D(1:(end-1), 1);
outputType = 0;
if(sum(b < 0) > 0) % not feasible so initialize dictionary
    % initial dictionary infeasible hence perform initialization
    % initialization phase simplex
    [outputType, D, xB, xI] = initialize(D, xB, xI);
end

if(outputType == 0)
    % run optimization on initialized primal dictionary
    [outputType, D_star, xB_star, xI_star] = optimize(D, xB, xI);
else
    D_star = D;
    xB_star = xB;
    xI_star = xI;
end
end