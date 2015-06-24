function testArr(x)
%%%%%
%% This function is used to test if matlab function can be used to pass array
%% Input: x is an array
%% Output: x[1]
%% Author: Yin Huang
%% Date: Dec, 1, 2014
if(length(x)>0)
disp(['The first element in x is: ' num2str(x(1))]);
else
disp(['Sorry x has no element!']);
end
end
