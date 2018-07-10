function [outputType D_k xB_k xI_k] = initialize(D, xB, xI)

% change the objective function of the primal dictionary
D0 = D;
% D0(end, 2:end) = -1;

% convert to dual dictionary
xypairs = createComplementaryPairs(xB, xI); % create complementary pairs
[dual_D, yB, yI] = convertToDual(D0, xB, xI, xypairs, 1);

% run optimization phase simplex on dual dictionary
[dual_outputType, dual_Dnew, yBnew, yInew] = optimize(dual_D, yB, yI);

if(dual_outputType == -1) % dual is unbounded implies primal is infeasible
    outputType = 2;
    D_k = D;    
    xB_k = xB;
    xI_k = xI;
elseif(dual_outputType == 2) % dual is infeasible implies primal is unbounded
    outputType = -1;
    D_k = D;    
    xB_k = xB;
    xI_k = xI;    
elseif (dual_outputType == 1) % dual is feasible and final implies primal is feasible
    outputType = 0;
    % dual is final ==> primal is initialized
    % convert dual final dictionary to primal feasible dictionary for optimization
    [D_k, xB_k, xI_k] = convertToDual(dual_Dnew, yBnew, yInew, xypairs, 0); % dual of dual is primal
    
    % replace original objective function
    len = size(xI, 1);
    objective_row = zeros(1, size(D_k, 2));
    c = D(end, 2:end); % original objective coefficients
    for i = 1:len
        xi = xI(i);
        idxb = find(xB_k == xi);
        if(~isempty(idxb))
            objective_row = objective_row + c(i)*D_k(idxb, :);
        else
            idxi = find(xI_k == xi);
            objective_row(idxi+1) = objective_row(idxi+1) + c(i);
        end
    end
    D_k(end, :) = objective_row;
end
end