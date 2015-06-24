myDB;
vector = DB('65536lz_q1');
tic;
x=vector(:,:);
time=toc;
whos;
disp(['Reading the vector costs ' num2str(time) 's']);
