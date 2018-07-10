function [outputType Dnew xBnew xInew] = singlePivot(D, xB, xI)
	% extract variables form the dictionary
	m = size(D, 1) - 1;
	n = size(D, 2) - 1;
	b = D(1:m, 1);
	A = -D(1:m, 2:(n+1));
	z = D(m+1, 1);
	c = transpose(D(m+1, 2:(n+1)));

	%% check if the dictionary is final
	final_dict = sum(c <= 0);
	if final_dict == size(c, 1);
		outputType = 1;
		Dnew = D;
		xBnew = xB;
		xInew = xI;
	else
		% Find Entering variable
		% Entering variables are non-basic variables whos coeffieients are >= 0;
		% Check if the dictionary is final
		% if the coefficients of all the non-basic variables are negative
		% then there is no entering variable and the dictionary is final
		enter_vars = xI(c > 0); % all the entering variables
		enter_var = min(enter_vars); % entering varialbe with the smallest index
		[enter_j, dummy] = find(xI == enter_var);
		
		% Check if the LP is unbounded
		% Unbounded := if the coeffcients in matrix A corresponding the
		% entering varialbe are all non-negative then the problem is unbounded
		Aj = D(1:m, enter_j + 1); % coefficients corresponding to entering variable
		if sum(Aj >=  0) == size(Aj, 1)
		    outputType = -1;        % if all are negative then problem is unbounded
		    Dnew = D;
		    xBnew = xB;
		    xInew = xI;
		else
		    outputType = 0;
		    % Leaving Variable
		    leave_var_indexes = find(Aj < 0);
		    leave_var_candidates = xB(leave_var_indexes);
		    bounds = -b(leave_var_indexes)./Aj(leave_var_indexes);
		    min_bound = min(bounds);
		    leave_var_with_min_bound = leave_var_candidates(bounds == min_bound); % more than one leaving variable can have the same min bound
		    leave_var = min(leave_var_with_min_bound); % among the leaving variables with minimum bounds choose one with min index.
		    leave_i = find(xB == leave_var);
		    
		    
		    Dtemp = [D zeros(m+1, 1)];
		    
		    leaving_var_modified_row = [D(leave_i, :)/(-D(leave_i, enter_j+1)), -1/(-D(leave_i, enter_j+1))];
		    entering_var_coeffs = D(:, enter_j + 1);
		    %      temp_matrix = repmat(leaving_var_modified_row, m+1, 1).*entering_var_coeffs;
		    temp_matrix = diag(entering_var_coeffs)*repmat(leaving_var_modified_row, m+1, 1);
		    Dnew = Dtemp + temp_matrix;
		    Dnew(leave_i, :) = leaving_var_modified_row;
		    Dnew(:, enter_j+1) = [];
		    
		    xInew = [xI; leave_var];
		    xInew(enter_j) = [];
		    [xInew, idx] = sort(xInew);
		    idx = [1; 1+idx];
		    Dnew = Dnew(:, idx);
		    
		    xBnew = xB;
		    xBnew(leave_i, 1) = enter_var;
		    [xBnew, idx] = sort(xBnew);
		    idx = [idx; m+1];
		    Dnew = Dnew(idx, :);
		end
	end
end
