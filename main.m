% Example Data file format
% 3 4 --- m x n
% 1 3 6 --- basic variables
% 2 4 5 7 -- non basic variables
% 1 3 0  ---- b coefficients
% 0 0 -1 -2  --- Row 1 of matrix A
% 1 -1 0 -1  --- Row 2 of matrix A
% -1 0 -2 0  --- Row m of matrix A
% 1 -1  2 3 1 --- fist column is z and the last n columns are c
% outputTypes:  1 -- final dictionary
%               0 -- intermediate dictionary
%               -1 -- unbounded dictionary
%               2 -- infeasible dictionary
% ilp_flag: 1 -- solve ILP problem
%           0 -- solve LP problem
clear all
data = dlmread('./ilpTests/assignmentTests/part5.dict');
% data = dlmread('./ilpTests/unitTests/ilpTest6');
m = data(1,1); % number of constraints
n = data(1,2); % number of decision variables
xB = transpose(data(2, 1:m));
xI = transpose(data(3, 1:n));
b = transpose(data(4, 1:m));
A = -data(5:(5+(m-1)), 1:n);
z = data(end, 1);
c = transpose(data(end, 2:(n+1)));
D = [b, -A; [z, c']]; % primal dictionary

ilp_flag = 1; 
if(ilp_flag == 1)
    [outputType, D_star, xB_star, xI_star] = ilpSolve(D, xB, xI);
else
    [outputType, D_star, xB_star, xI_star] = lpSolve(D, xB, xI);    
end

D_star(end , 1)
% if (outputType == 1)
%     optimal_objective = D_star(end , 1)
% elseif (outputType == -1)
%     optimal_objective = 'Unbounded'
% elseif(outputType == 2)
%     optimal_objective = 'Infeasible'
% end