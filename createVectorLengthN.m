function x = createVectorLengthN(n)
y = ones(n,1);
i = 1;
while(i<=n)
  fprintf(1,'%d\n',y(i));
i=i+1;
end
