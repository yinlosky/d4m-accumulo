% vector v: length = m+2 v_0 and v_m+1 are useless
% Arr alpha length = m
% Arr beta length = m+1

Arr_Vector = cell(1,5); 
Arr_Alpha = zeros(1,3);
Arr_Beta = zeros(1,4);

% initialize v_0 arr v is a column vector first argument is the size of the input matrix n
Arr_Vector{1} = zeros(3,1); 
% initialize the randam vector b, first argument is the size of the input matrix n
Vector_b =rand(3,1); 
%initialize v_1: v1 = b/||b||
Arr_Vector{2} = Vector_b ./ norm(Vector_b); 
%initialize our input matrix A n*n, here we have 3X3
A = [1,2,3;4,5,6;7,8,9];  

%for loop 1:m
for i = 1:3  		
% V = A*V_i;
   Vector_V = A*Arr_Vector{i+1};
% alpha_i = V_i'*V
    Arr_Alpha(i) = Arr_Vector{i+1}'*Vector_V;
% V = V - (beta_i-1 * V_i-1) -  (alpha_i * V_i)
  Vector_V = Vector_V - Arr_Beta(i)*Arr_Vector{i} - Arr_Alpha(i)*Arr_Vector{i+1};
% beta_i = ||V|| 
Arr_Beta(i+1) = norm(Vector_V);

	%if(i == 1)
	%T_var = diag(Arr_Alpha(1));
	%else
        %main_diagonal = Arr_Alpha(1:i);
  	%off_diagonal = Arr_Beta(2:i+1);
   	%T_var = diag(main_diaggnal) + diag(off_diagonal,1) + diag(off_diagonal,-1);
	%end
        %[Tq,Td] = eig(T_var);
	%for j = 1:i
	%	if


% V_i+1 = V / beta_i
  Arr_Vector{i+2} = Vector_V ./ Arr_Beta(i+1);
end
  %%construct tridiagonal matrix T from alpha(1:m) and beta(2:m) 
  main_diagonal = Arr_Alpha(1:3);
  off_diagonal = Arr_Beta(2:3);
  T = diag(main_diagonal) + diag(off_diagonal,1) + diag(off_diagonal,-1);
%% TQ = QD;
  [Q,D] = eig(T);     
  eigVals = diag(D); 
  eigVals
%%construct matrix from cell array V
  Vector_m = cell2mat(Arr_Vector);
%% remove v_0 and V_m+1  we need v_1 to v_m the index is from 1+1 to m+1
  Vector_m = Vector_m(:,2:4);
%% get the first K columns of Q
  Q = Q(:,1:3)
%% Our eigen Vector : V_m(n*m) * Q_k(m*k)
  eigVec = Vector_m*Q;	
  eigVec



