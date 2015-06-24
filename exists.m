function Yes = exists(DB, T)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% this function will tell if a table exists in the DB, name exact match
%%% If exists return 1 else 0
%%% DB: the database object
%%% T: is the name of the table
%%% Author: Yin Huang
%%% Date: Nov-25-2014
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tables = textscan(ls(DB),'%s');
tables = tables{1};
if (find(ismember(tables,T)))
	Yes = 1;
else Yes =0;
end
end
