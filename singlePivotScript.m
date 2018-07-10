% input
clear all
D = importdata('debugdict.txt');
xB = importdata('xBnew.txt');
xI = importdata('xInew.txt');
  
  
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
    enter_vars = xI(find(c > 0)); % all the entering variables  
    enter_var = min(enter_vars); % entering varialbe with the smallest index
    [enter_j, dummy] = find(xI == enter_var);  
    
    % check if the problem is unbounded    
    Aj = D(1:m, enter_j + 1); % coefficients corresponding to entering variable
    if sum(Aj >=  0) == size(Aj, 1)
      outputType = -1;        % if all are negative then problem is unbounded
      Dnew = D;
      xBnew = xB;
      xInew = xI;      
    else
      outputType = 0;
      
      % Leaving Variable 
      % Check if the LP is unbounded
      % Unbounded := if the coeffcients in matrix A corresponding the 
      % entering varialbe are all non-negative then the problem is unbounded          
      leave_var_indexes = find(Aj < 0);
      leave_var_candidates = xB(leave_var_indexes);
      coeffs = Aj(leave_var_indexes);
      bounds = -b(leave_var_indexes)./coeffs;    
      min_bound = min(bounds);
      leave_var_with_min_bound = leave_var_candidates(find(bounds == min_bound)); % more than one leaving variable can have the same min bound
      leave_var = min(leave_var_with_min_bound); % among the leaving variables with minimum bounds choose one with min index.    
      leave_i = find(xB == leave_var);
      
      % new basic and non-basic variables
      xInew = zeros(n, 1);
      xInew = [xI(1:(enter_j-1), 1); xI((enter_j+1):n, 1); leave_var];
      xBnew = zeros(m, 1);
      xBnew(1,1) = enter_var;
      xBnew(2:m) = [xB(1:(leave_i - 1), 1); xB((leave_i+1):m, 1)];

      Dnew = zeros(m+1, n+1);
      Dtemp = [D zeros(m+1, 1)];
      
      leaving_var_modified_row = [D(leave_i, :), -1]/(-D(leave_i, enter_j+1));
      entering_var_coeffs = D(:, enter_j + 1);
      temp_matrix = repmat(leaving_var_modified_row, m+1, 1).*entering_var_coeffs;  
      Dnew = Dtemp + temp_matrix;
      Dnew = [leaving_var_modified_row; Dnew];
      Dnew(:, enter_j+1) = [];
      Dnew(leave_i + 1, :) = [];
      
      xInew = [xI; xB(leave_i)];
      xInew(enter_j) = [];
      [xInew, idx] = sort(xInew);
      idx = [1; 1+idx];
      Dnew = Dnew(:, idx);
      
      xBnew = [xI(enter_j);xB];
      xBnew(leave_i) = [];
      [xBnew, idx] = sort(xBnew);
      idx = [idx; m+1];
      Dnew = Dnew(idx, :);
    end   
  end