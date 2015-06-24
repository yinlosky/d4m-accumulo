%%% Begin script %%%

% Make a tridiagonal matrix with all fours on the main diagonal, and all ones
% on both the sub-diagonal and super-diagonal.
%
% n is the dimension of the n-by-n tridiagonal matrix T.

     n = 10;
main_diagonal = 4 * ones(n, 1);
off_diagonal = ones(n - 1, 1);
T = diag(main_diagonal) + diag(off_diagonal, 1) + diag(off_diagonal, -1)

%%% End script %%% 
