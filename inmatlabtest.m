DB = DBserver('localhost:2181','Accumulo','myaccumulo','root','123456');
test = DB('InputMatrix');
[r,c,v] = test(:,'1,2,3,4,');