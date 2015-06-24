function testiterator(NumOfNodes,d)
myDB;
m= DB(['M' num2str(NumOfNodes)]);
num = DB(['Entries' num2str(NumOfNodes)]);
query = sprintf('%d,',1:d);
[mr,mc,maxCol] = num(query,:);
disp(['maxCol is ' sprintf('\n')]);
maxCol = str2num(maxCol)'
this = tic;
for i =1:d
mIt = Iterator(m,'elements',maxCol(i));
E = mIt(sprintf('%d,',i),:);
size(E)
end
time = toc(this);
disp(['Query with iterator time is: ' num2str(time) ' s']);

end
