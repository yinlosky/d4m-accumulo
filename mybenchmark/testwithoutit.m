function testwithoutit(NumOfNodes,d)
myDB;
m= DB(['M' num2str(NumOfNodes)]);
num = DB(['Entries' num2str(NumOfNodes)]);

query = sprintf('%d,',1:d);
this = tic;
for i =1:d;
x = m(sprintf('%d,',i),:);
end
time = toc(this);
disp(['Query: ' query  ' without iterator time is: ' num2str(time) ' s']);
end
