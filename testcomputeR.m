function testcomputeR()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% This is to test computeR.m
%%
%% Author: Yin Huang
%% Date: 12,2,2014
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Generate 5 lz_q tables in accumulo.
myDB;
q1 = DB('lz_q1');
q2 = DB('lz_q2');
q3 = DB('lz_q3');
q4 = DB('lz_q4');
q5 = DB('lz_q5');
x = '1,2,3,4,5,';
y = '1,1,1,1,1,';
myA = Assoc(x,y,x);
put(q1,myA);
put(q2,myA);
put(q3,myA);
put(q4,myA);
put(q5,myA);
myQ = [1,2,3,4;2,3,4,5;3,4,5,6;4,5,6,7];
result = computeR(3,2,myQ, 5, 2)

%%%%%%%%%%%%%%%%%%%%%seems to be working%%%%%%%%%%%%%%%%%
