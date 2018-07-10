function [dual_D, yB, yI] = convertToDual(D, xB, xI, xypairs, dual_flag)
%%%%% OLD CODE %%%%%%
% % % convert to dual dictionary
% % m = size(D, 1) - 1;
% % n = size(D, 2) - 1;
% % dual_m = n;
% % dual_n = m;
% % 
% % % xB complements
% % [dummy idx] = ismember(xB, xypairs(:, 1));
% % yI = xypairs(idx, 2);
% % % xI complements
% % [dummy idx] = ismember(xI, xypairs(:, 1));
% % yB = xypairs(idx, 2);
% % if(size(yI) ~= dual_n | size(yB) ~= dual_m)
% %     error(['yI should be of length',num2str(dual_n),'long and yB shold be of length', num2str(dual_m)])
% % end
% % dual_b = -transpose(D(end, 2:(n+1)));
% % dual_A = -transpose(D(1:m, 2:(n+1)));
% % dual_c = -D(1:m, 1);
% % dual_z = -D(m+1, 1);
% % dual_D = [dual_b, dual_A; [dual_z, dual_c']];




%% new code
dual_D = -transpose(D);
dual_D = circshift(dual_D, [-1 1]);

dual_m = size(dual_D, 1) - 1;
dual_n = size(dual_D, 2) - 1;

if(dual_flag == 1) % converting from primal to dual
    % xB complements
    [dummy idx] = ismember(xB, xypairs(:, 1));
    yI = xypairs(idx, 2);
    % xI complements
    [dummy idx] = ismember(xI, xypairs(:, 1));
    yB = xypairs(idx, 2);
elseif(dual_flag == 0) % converting from dual to primal
    % xB complements
    [dummy idx] = ismember(xB, xypairs(:, 2));
    yI = xypairs(idx, 1);
    % xI complements
    [dummy idx] = ismember(xI, xypairs(:, 2));
    yB = xypairs(idx, 1);
end
    if(size(yI) ~= dual_n | size(yB) ~= dual_m)
        error(['yI should be of length ',num2str(dual_n),' and yB shold be of length', num2str(dual_m)])
    end
