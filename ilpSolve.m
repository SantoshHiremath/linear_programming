function [outputType, D_star, xB_star, xI_star] = ilpSolve(D, xB, xI)
    % solve the LP relaxation problem
    % Assumptions: 
    % 1) It is assumed that  Assume that the  problem and slack variables 
    %    in the given dictionary are integer valued. 
    % 2) Even if the dictionary has floating point entries, start with the 
    %    given input dictionary, and do not attempt to scale the problem.
    
%     [outputType, D_lprelax, xB_lprelax, xI_lprelax] = optimize(D, xB, xI);
    [outputType, D_lprelax, xB_lprelax, xI_lprelax] = lpSolve(D, xB, xI);
    while(outputType == 1)        
        % check for integrality
        b = D_lprelax(1:(end - 1), 1);
        tol = 10e-6;
        if(sum(abs(round(b) - b) <= tol) == size(b, 1)) % integral solution found
            outputType = 3;
        else % LP relaxation was gave optimal or unbounded
            outputType = 0;
            % add cutting plane and
            % choose the smallest index amomg the indices of non
            % integral elements of b
            non_integer_idx = find(abs(round(b) - b) > tol); % find indices of non integer basic variables
            nfloats = size(non_integer_idx, 1);
            D_lprelax_with_cutting_plane = D_lprelax;
            xB_lprelax_with_cutting_plane = xB_lprelax;
            for i = 1:nfloats
                idx = non_integer_idx(i);
                cutting_plane_row = D_lprelax(idx, :);
                cutting_plane = -cutting_plane_row - floor(-cutting_plane_row);
                cutting_plane(1, 1) = -(cutting_plane_row(1) - floor(cutting_plane_row(1)));
                D_lprelax_with_cutting_plane = [cutting_plane;D_lprelax]; % add cutting plane to the dictionary
                new_var = max([xB_lprelax; xI_lprelax]) + 1;
                xB_lprelax_with_cutting_plane = [new_var;xB_lprelax]; % add new variable to basic variable list
            end
            
            % The new dictionary is primal infeasible but dual feasile so
            % convert to dual
            xypairs = createComplementaryPairs(xB_lprelax_with_cutting_plane, xI_lprelax); % create complementary pairs
            [dual_D, yB, yI] = convertToDual(D_lprelax_with_cutting_plane, xB_lprelax_with_cutting_plane, xI_lprelax, xypairs, 1);
            % run optimization phase simplex on dual dictionary
            [dual_outputType, dual_D_lprelax, yB_lprelax, yI_lprelax] = optimize(dual_D, yB, yI);
            % convert to primal
            [D_lprelax, xB_lprelax, xI_lprelax] = convertToDual(dual_D_lprelax, yB_lprelax, yI_lprelax, xypairs, 0); % dual of dual is primal
            if(dual_outputType == -1) % dual is unbounded implies primal is infeasible
                outputType = 2;
            elseif(dual_outputType == 2) % dual is infeasible implies primal is unbounded
                outputType = -1;
            elseif (dual_outputType == 1) % dual is feasible and final implies primal is feasible
                outputType = 1;
            end
        end
    end
    D_star = D_lprelax;
    xB_star = xB_lprelax;
    xI_star = xI_lprelax;
end