function A = ScalarMult(x, y, NumOfNodes, NumOfMachines)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Scalar multiply matrix will call ScalarM(x, 'smult_output', y)
%%% That's to say the result will always be written to the table called smult_output, it's up to the coder to save this table 
%%% Author: Yin Huang
%%% Date: Nov-25-2014
%%% Usage: ScalarMult('B','BScalar',2^12,8)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ScalarM(x,'smult_output',y, NumOfNodes, NumOfMachines);
A = 'smult_output';
end
