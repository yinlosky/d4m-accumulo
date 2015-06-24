myDB;
m =DB('16384lz_q1');
[mr,mc,mv]=m(sprintf('%d,',1:23),:);
mv
for i = 1:23
	disp([Val(m(sprintf('%d,',i),:))]);
	end	

