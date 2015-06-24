% Matlab code LanczosSelectOrthog.m
% For "Applied Numerical Linear Algebra",  Chapter 7, section 5
% Written by James Demmel, Jun  6, 1997
%
% Perform Lanczos with selective orthogonalization
%
% Inputs:
%
%   A = input matrix (may be sparse)
%   e = true eigenvalues, sorted from largest to smallest
%   q = starting vector for Lanczos
%   m = number of Lanczos steps to take
%   mm1,mm2 = indices of extreme eigenvalues for which to plot error 
%             and error bounds 
%   mine, maxe = range in which to plot eigenvalues
%   steplabel = array of values at which to draw vertical lines in plots
%   recomp = 1 to perform algorithm from scratch
%          = 0 just to redisplay data, with possibly different
%               mine, maxe, mm1, mm2, steplabel
%   whichbound = 2 to plot all errors and error bounds
%              = 1 to plot local error and error bounds
%              = 0 to plot error bounds only
%   displayselection = 1 to display details of which Ritz vectors 
%                      are selected, as Lanczos runs
%                    = 0 not to display details
%
%
% Outputs:
%
%   plot of Ritz values for all m Lanczos steps, in range [mine,maxe]
%    (figure 1)
%
%   plots of global error (distance from final eigenvalue) (if whichbound=2)
%            local error (distance from closest eigenvalue) (if whichbound=1)
%            error bound (provided by Lanczos algorithm)
%     for mm1 to mm2 smallest and mm1 to mm2 largest eigenvalues
%    (figures 2 and 3)
%
%   plots of components of each eigenvector in current Lanczos vector
%            (only valid if A is diagonal with eigenvalues sorted
%            from largest to smallest!)
%     for mm1 to mm2 smallest and mm1 to mm2 largest eigenvalues
%    (figures 4 and 5)
%
%   plots of components of each vector in current Lanczos vector
%           (only valid if A is diagonal with eigenvalues sorted
%            from largest to smallest!)
%           and error bounds
%     for mm1 to mm2 smallest and mm1 to mm2 largest eigenvalues
%    (figures 6 and 7)
%
%   plot of singular values of matrix of first k Lanczos vectors, for k=1:m
%    (only if recomp=1)
%    (figure 8)
%
%  plot of indices of Ritz vectors selected for orthogonalization
%    (figure 9)
%
%  plot of Ritz values selected for orthogonalization
%    (figure 10)
%
linewidth = 2;
linewidthd = 4;
markersize = 8;
if (recomp==1)  % {
   n=max(size(A));
   EvalFLSO = zeros(m,m);
   ErrorBoundsFLSO = zeros(m,m);
   RitzComponentsFLSO = zeros(m,m);
   SelectFLSO = 0;
   qq = q/norm(q);
   QFLSO = qq;
   clear alpha
   clear beta

   disp('start performing Lanczos with selective orthogonalization')
   disp('print step number')
   for i=1:m
      if (rem(i,10)==0) i, end
      z = A*qq;
      alpha(i) = qq'*z;
      z = z - alpha(i)*qq;
      if (i>1) z = z - beta(i-1)*QFLSO(:,i-1); end
      beta(i) = norm(z);
      qq = z/beta(i);
      qqorig = qq;
%
%     selectively orthogonalize, when the error bound < sqrt(eps)
      if (i>1),
         Ti = diag(alpha(1:i)) + diag(beta(1:i-1),1) + diag(beta(1:i-1),-1);
      else
         Ti = alpha(1);
      end
      [V,D] = eig(Ti);
%     sort eigenvalues into decreasing order
      [Ds,Is] = sort(-diag(D));
      EvalFLSO(1:i,i) = -Ds;
      Vs = V(:,Is);
      ErrorBoundsFLSO(1:i,i) = abs((beta(i)*Vs(i,:))');
      select = find( ErrorBoundsFLSO(1:i,i) <= sqrt(eps)*max(abs(Ds)) );
      if (length(select) > 0),
        SelectFLSO(1:length(select),i) = select;
        for s = select',
          ritzvector = QFLSO*Vs(:,s);
          z = z - (ritzvector'*z)*ritzvector;
        end
        beta(i) = norm(z);
        qq = z/beta(i);
      else
        SelectFLSO(1,i) = 0;
      end
%
      QFLSO = [QFLSO,qq];
      RitzComponentsFLSO(1:i,i) = ((QFLSO(:,i+1)'*QFLSO(:,1:i))*Vs)';
      if (displayselection == 1)
         if (length(select)>0)
            disp(['Lanczos step = ',int2str(i)]),
            OrigRitzComponent = ((qqorig'*QFLSO(:,1:i))*Vs)';
            disp('   Number of    Error       Selected     Original     Ritz')
            disp('   selected     Bound       Ritz         Ritz         Component')
            disp('   Ritz         over        Value        Component    After')
            disp('   Vector       norm(T)                               Selective')
            disp('                                                      Orthogonalization')
            format short e
            [select, ErrorBoundsFLSO(select,i)/max(abs(Ds)), ...
             EvalFLSO(select,i), OrigRitzComponent(select), ...
             RitzComponentsFLSO(select,i)]
            disp('pause (hit return to continue)'), pause
         end
      end
   end
%
%  Compute singular values of matrices of Lanczos vector
%
   [qQ,rQ] = qr(QFLSO(:,1:m),0);
   clear smin,
   for i = 1:m, smin(i) = min(svd(rQ(1:i,1:i))); end
   disp('Distance from 1 of smallest singular value of Lanczos vector matrix:')
   sminx=1-smin(m)
   disp('done with extracting eigenvalues, bounds')
   disp('pause (hit return to continue)'), pause
end % }
%
% Produce graph of converging Ritz values 
%
figure(1)
hold off, clf
for j=1:ceil(m/2),
    rr = 2*j-1;
    if (rem(j,4)==1),
       str='k+';
    elseif (rem(j,4)==2),
       str='r+';
    elseif (rem(j,4)==3),
       str='g+';
    elseif (rem(j,4)==0),
       str='b+';
    end
    deval = diag(EvalFLSO,j-1);deval=deval(j:m-j+1);
    hndl=plot(rr:m,EvalFLSO(j,rr:m),str); 
    set(hndl,'MarkerSize',markersize);
    hold on
    hndl=plot(rr:m,deval,str);
    set(hndl,'MarkerSize',markersize);
end
hndl=plot((m+1)*ones(size(e)),e,'k+');
set(hndl,'MarkerSize',markersize);
axis([0,m+2,mine,maxe])
for b=steplabel, plot([b,b],[mine,maxe],'k:'); end
title([int2str(m),' steps of Lanczos (selective orthogonalization) applied to A'])
xlabel('Lanczos step'), ylabel('Eigenvalues')
disp('done with figure 1')
disp('pause (hit return to continue)'),pause
%
% Produce graph of errors, error bounds in largest mm1 to mm2 Ritz values
%
figure(2)
hold off, clf
step = 3;
for js=mm1:step+1:mm2
  hold off, clf
  for j=js:min(js+step,mm2)
    if (rem(j,4)==1),
       str='k';
       strB='--k';
       strD=':k';
    elseif (rem(j,4)==2),
       str='r';
       strB='--r';
       strD=':r';
    elseif (rem(j,4)==3),
       str='g';
       strB='--g';
       strD=':g';
    elseif (rem(j,4)==0),
       str='b';
       strB='--b';
       strD=':b';
    end
    disp(['Eigenvalue being plotted = ',num2str(e(j))]),
%   plot global error
    if (whichbound > 1),
       hndl=semilogy((j:m),abs(EvalFLSO(j,j:m)-e(j))/(abs(e(j))),str);
       set(hndl,'LineWidth',linewidth);
       set(hndl,'MarkerSize',markersize);
       hold on
    end
%   plot local error
    if (whichbound > 0),
       hndl=semilogy((j:m), ...
         min(abs(ones(size(e))*EvalFLSO(j,j:m)-e*ones(1,m-j+1)))/(abs(e(j))),strD);
       set(hndl,'LineWidth',linewidthd);
       set(hndl,'MarkerSize',markersize);
       hold on
    end
%   plot error bound
    hndl=semilogy((j:m),ErrorBoundsFLSO(j,j:m)/(abs(e(j))),strB);
    set(hndl,'LineWidth',linewidth);
    set(hndl,'MarkerSize',markersize);
    hold on
  end
  axis([0,m+1,1e-16,1])
  jsend = min(js+step,mm2);
  if (whichbound > 1),
   if (jsend ~= js),
      title(['True errors and error bounds, in eigenvalues ',int2str(js), ...
          ' to ', int2str(min(js+step,mm2))])
   else
      title(['True errors and error bounds, in eigenvalue ',int2str(js)])
   end
   xlabel('Lanczos step (selective orthogonalization)'), 
   ylabel('Global Error (solid), Local Error (dotted), Bound (dashed)')
  elseif (whichbound > 0),
   if (jsend ~= js),
      title(['True local error and error bounds, in eigenvalues ',int2str(js), ...
          ' to ', int2str(min(js+step,mm2))])
   else
      title(['True local error and error bounds, in eigenvalue ',int2str(js)])
   end
   xlabel('Lanczos step (selective orthogonalization)'), 
   ylabel('Local Error (dotted), Bound (dashed)')
  else
   if (jsend ~= js),
      title(['Error bounds, in eigenvalues ',int2str(js), ...
          ' to ', int2str(min(js+step,mm2))])
   else
      title(['Error bounds, in eigenvalue ',int2str(js)])
   end
   xlabel('Lanczos step (selective orthogonalization)'), 
  end
  for b=steplabel, plot([b,b],[1e-16,1],'k:'); end
  disp('pause (hit return to continue)'), pause
end
disp('done with figure 2')
disp('pause (hit return to continue)'), pause
%
% Produce graph of errors, error bounds in smallest mm1 to mm2 Ritz values
%
figure(3)
hold off, clf
for js=mm1:step+1:mm2
  hold off, clf
  for j=js:min(js+step,mm2)
    if (rem(j,4)==1),
       str='k';
       strB='--k';
       strD=':k';
    elseif (rem(j,4)==2),
       str='r';
       strB='--r';
       strD=':r';
    elseif (rem(j,4)==3),
       str='g';
       strB='--g';
       strD=':g';
    elseif (rem(j,4)==0),
       str='b';
       strB='--b';
       strD=':b';
    end
    deval = diag(EvalFLSO,j-1); deval=deval(1:m-j+1);
    deval = deval';
    disp(['Eigenvalue being plotted = ',num2str(e(n+1-j))]),
%   plot global error
    if (whichbound > 1),
       hndl=semilogy((j:m),abs(deval-e(n+1-j))/max(abs(e)),str);
       set(hndl,'LineWidth',linewidth);
       set(hndl,'MarkerSize',markersize);
       hold on
    end
%   plot local error
    if (whichbound > 0),
       hndl=semilogy((j:m), ...
         min(abs(ones(size(e))*deval-e*ones(1,m-j+1)))/(abs(e(j))),strD);
       set(hndl,'LineWidth',linewidthd);
       set(hndl,'MarkerSize',markersize);
       hold on
    end
    devalbnd = diag(ErrorBoundsFLSO,j-1); devalbnd = devalbnd(1:m-j+1);
%   plot error bound
    hndl=semilogy((j:m),devalbnd/max(abs(e)),strB);
    set(hndl,'LineWidth',linewidth);
    set(hndl,'MarkerSize',markersize);
    hold on
  end
  for b=steplabel, plot([b,b],[1e-16,1],'k:'); end
  axis([0,m+1,1e-16,1])
  jsdif = (n+1-js)-(n+1-min(js+step,mm2));
  if (whichbound > 1),
   if (jsdif ~= 0)
      title(['True errors and error bounds, in eigenvalues ', ...
          int2str(n+1-min(js+step,mm2)),' to ', int2str(n+1-js)])
   else
      title(['True errors and error bounds, in eigenvalue ',  ...
          int2str(n+1-min(js+step,mm2))])
   end
   xlabel('Lanczos step (selective orthogonalization)'), 
   ylabel('Global Error (solid), Local Error (dotted), Bound (dashed)')
  elseif (whichbound > 0),
   if (jsdif ~= 0)
      title(['True local error and error bounds, in eigenvalues ', ...
          int2str(n+1-min(js+step,mm2)), ' to ', int2str(n+1-js)])
   else
      title(['True local error and error bounds, in eigenvalue ', ...
          int2str(n+1-min(js+step,mm2))])
   end
   xlabel('Lanczos step (selective orthogonalization)'), 
   ylabel('Local Error (dotted), Bound (dashed)')
  else
   if (jsdif ~= 0)
      title(['Error bounds, in eigenvalues ',int2str(n+1-min(js+step,mm2)), ...
          ' to ', int2str(n+1-js)])
   else
      title(['Error bounds, in eigenvalue ',int2str(n+1-min(js+step,mm2))])
   end
   xlabel('Lanczos step (selective orthogonalization)'), 
  end
  disp('pause (hit return to continue)'), pause
end
disp('done with figure 3')
disp('pause (hit return to continue)'), pause
%
% Plot components of Lanczos vectors for largest mm1 to mm2 eigenvectors
%
figure(4)
hold off, clf
for js=mm1:step+1:mm2
  hold off, clf
  for j=js:min(js+step,mm2)
    if (rem(j,4)==1),
       str='k';
       strB='--k';
       strQp='+k';
       strQn='ok';
    elseif (rem(j,4)==2),
       str='r';
       strB='--r';
       strQp='+r';
       strQn='or';
    elseif (rem(j,4)==3),
       str='g';
       strB='--g';
       strQp='+g';
       strQn='og';
    elseif (rem(j,4)==0),
       str='b';
       strB='--b';
       strQp='+b';
       strQn='ob';
    end
    disp(['Eigenvalue being plotted = ',num2str(e(j))]),
    Qpos = find(QFLSO(j,1:m)>0);
    Qneg = find(QFLSO(j,1:m)<0);
    hndl=semilogy(Qpos,abs(QFLSO(j,Qpos)),strQp);
    set(hndl,'LineWidth',linewidth);
    set(hndl,'MarkerSize',markersize);
    hold on
    hndl=semilogy(Qneg,abs(QFLSO(j,Qneg)),strQn);
    set(hndl,'LineWidth',linewidth);
    set(hndl,'MarkerSize',markersize);
    axis([0,m+1,1e-16,1])
  end
  axis([0,m+1,1e-16,1])
  if (js ~= min(js+step,mm2))
     title(['Lanczos vector components for eigenvectors  ',int2str(js), ...
         ' to ', int2str(min(js+step,mm2))])
  else
     title(['Lanczos vector components for eigenvector  ',int2str(js)])
  end
  xlabel('Lanczos step (selective orthogonalization)'), ylabel('eigencomponent (+ = pos, o = neg)')
  for b=steplabel, plot([b,b],[1e-16,1],'k:'); end
  for b = [1e-12 1e-8 1e-4], plot([0,m+1],[b,b],'k:'); end
  disp('pause (hit return to continue)'), pause
end
disp('done with figure 4')
disp('pause (hit return to continue)'), pause
%
% Plot components of Lanczos vectors for smallest mm1 to mm2 eigenvectors
%
figure(5)
hold off, clf
for js=mm1:step+1:mm2
  hold off, clf
  for j=js:min(js+step,mm2)
    if (rem(j,4)==1),
       str='k';
       strB='--k';
       strQp='+k';
       strQn='ok';
    elseif (rem(j,4)==2),
       str='r';
       strB='--r';
       strQp='+r';
       strQn='or';
    elseif (rem(j,4)==3),
       str='g';
       strB='--g';
       strQp='+g';
       strQn='og';
    elseif (rem(j,4)==0),
       str='b';
       strB='--b';
       strQp='+b';
       strQn='ob';
    end
    disp(['Eigenvalue being plotted = ',num2str(e(n+1-j))]),
    Qpos = find(QFLSO(n+1-j,1:m)>0);
    Qneg = find(QFLSO(n+1-j,1:m)<0);
    hndl=semilogy(Qpos,abs(QFLSO(n+1-j,Qpos)),strQp);
    set(hndl,'LineWidth',linewidth);
    set(hndl,'MarkerSize',markersize);
    hold on
    hndl=semilogy(Qneg,abs(QFLSO(n+1-j,Qneg)),strQn);
    set(hndl,'LineWidth',linewidth);
    set(hndl,'MarkerSize',markersize);
    end
  axis([0,m+1,1e-16,1])
  if (n+1-min(js+step,mm2) ~= n+1-js)
     title(['Lanczos vector components for eigenvectors ', ...
         int2str(n+1-min(js+step,mm2)), ' to ', int2str(n+1-js)])
  else
     title(['Lanczos vector components for eigenvector ',int2str(n+1-min(js+step,mm2))])
  end
  xlabel('Lanczos step (selective orthogonalization)'), ylabel('eigencomponent (+ = pos, o = neg)')
  for b=steplabel, plot([b,b],[1e-16,1],'k:'); end
  for b = [1e-12  1e-8  1e-4 ], plot([0,m+1],[b,b],'k:'); end
  disp('pause (hit return to continue)'), pause
end
disp('done with figure 5')
%
% Plot components of Lanczos vectors for largest mm1 to mm2 Ritz vectors
%
figure(6)
hold off, clf
for js=mm1:step+1:mm2
  hold off, clf
  for j=js:min(js+step,mm2)
    if (rem(j,4)==1),
       str='k';
       strB='--k';
       strQp='+k';
       strQn='ok';
       strD=':k';
    elseif (rem(j,4)==2),
       str='r';
       strB='--r';
       strQp='+r';
       strQn='or';
       strD=':r';
    elseif (rem(j,4)==3),
       str='g';
       strB='--g';
       strQp='+g';
       strQn='og';
       strD=':g';
    elseif (rem(j,4)==0),
       str='b';
       strB='--b';
       strQp='+b';
       strQn='ob';
       strD=':b';
    end
    disp(['Eigenvalue being plotted = ',num2str(e(j))]),
    Qpos = find(RitzComponentsFLSO(j,1:m)>0);
    Qneg = find(RitzComponentsFLSO(j,1:m)<0);
    hndl=semilogy(Qpos,abs(RitzComponentsFLSO(j,Qpos)),strQp);
    set(hndl,'LineWidth',linewidth);
    set(hndl,'MarkerSize',markersize);
    hold on
    hndl=semilogy(Qneg,abs(RitzComponentsFLSO(j,Qneg)),strQn);
    set(hndl,'LineWidth',linewidth);
    set(hndl,'MarkerSize',markersize);
%   plot error bound
    hndl=semilogy((j:m),ErrorBoundsFLSO(j,j:m)/(abs(e(j))),strB);
    set(hndl,'LineWidth',linewidth);
    set(hndl,'MarkerSize',markersize);
    axis([0,m+1,1e-16,1])
  end
  axis([0,m+1,1e-16,1])
  if (js ~= min(js+step,mm2))
     title(['Error Bounds and Lanczos vector components for Ritz vectors ', ...
          int2str(js), ' to ', int2str(min(js+step,mm2))])
  else
     title(['Error Bounds and Lanczos vector components for Ritz vector ', int2str(js)])
  end
  xlabel('Lanczos step (selective orthogonalization)'), ylabel('eigencomponent (+ = pos, o = neg), bound (dashed)')
  for b=steplabel, plot([b,b],[1e-16,1],'k:'); end
  for b = [1e-12 1e-8 1e-4], plot([0,m+1],[b,b],'k:'); end
  disp('pause (hit return to continue)'), pause
end
disp('done with figure 6')
disp('pause (hit return to continue)'), pause
%
% Plot components of Lanczos vectors for smallest mm1 to mm2 eigenvectors
%
figure(7)
hold off, clf
for js=mm1:step+1:mm2
  hold off, clf
  for j=js:min(js+step,mm2)
    if (rem(j,4)==1),
       str='k';
       strB='--k';
       strQp='+k';
       strQn='ok';
    elseif (rem(j,4)==2),
       str='r';
       strB='--r';
       strQp='+r';
       strQn='or';
    elseif (rem(j,4)==3),
       str='g';
       strB='--g';
       strQp='+g';
       strQn='og';
    elseif (rem(j,4)==0),
       str='b';
       strB='--b';
       strQp='+b';
       strQn='ob';
    end
    disp(['Eigenvalue being plotted = ',num2str(e(n+1-j))]),
    RitzComp = diag(RitzComponentsFLSO,j);
    Qpos = find(RitzComp>0);
    Qneg = find(RitzComp<0);
    hndl=semilogy(Qpos+j-1,abs(RitzComp(Qpos)),strQp);
    set(hndl,'LineWidth',linewidth);
    set(hndl,'MarkerSize',markersize);
    hold on
    hndl=semilogy(Qneg+j-1,abs(RitzComp(Qneg)),strQn);
    set(hndl,'LineWidth',linewidth);
    set(hndl,'MarkerSize',markersize);
    devalbnd = diag(ErrorBoundsFLSO,j-1); devalbnd = devalbnd(1:m-j+1);
%   plot error bound
    hndl=semilogy((j:m),devalbnd/max(abs(e)),strB);
    set(hndl,'LineWidth',linewidth);
    set(hndl,'MarkerSize',markersize);
    end
  axis([0,m+1,1e-16,1])
  if (n+1-min(js+step,mm2) ~= n+1-js),
     title(['Error Bounds and Lanczos vector components for Ritz vectors ', ...
          int2str(n+1-min(js+step,mm2)), ' to ', int2str(n+1-js)])
  else
     title(['Error Bounds and Lanczos vector components for Ritz vector ', ...
          int2str(n+1-min(js+step,mm2))])
  end
  xlabel('Lanczos step (selective orthogonalization)'), ylabel('eigencomponent (+ = pos, o = neg), bound (dashed)')
  for b=steplabel, plot([b,b],[1e-16,1],'k:'); end
  for b = [1e-12  1e-8  1e-4 ], plot([0,m+1],[b,b],'k:'); end
  disp('pause (hit return to continue)'), pause
end
MaxProdRitzCompErrorBounds = max(max(abs(ErrorBoundsFLSO .* RitzComponentsFLSO)));
disp('Maximum absolute entry of  ErrorBoundsFLSO .* RitzComponentsFLSO = ')
MaxProdRitzCompErrorBounds 
disp('done with figure 7')
disp('pause (hit return to continue)'), pause
%
%  Produce graph of singular values of Lanczos vectors
%
figure(8)
hold off, clf
hndl=semilogy((1:m),smin,'k');
set(hndl,'LineWidth',linewidth); hold on,
for b=steplabel, semilogy([b,b],[1e-16,1],'k:'); end
grid
title('Smallest singular value of first k Lanczos vectors')
xlabel('Lanczos step (selective orthogonalization)'),
ylabel(['Largest deviation from 1 = ',num2str(sminx)])
axis([0 m 1e-16 1])
disp('done with figure 8')
disp('pause (hit return to continue)'), pause
%
%  Produce plot of indices of Ritz vectors selected for orthogonalization
%
figure(9)
hold off, clf
SparseSelectFLSO = zeros(m,m);
for i=1:m
   pos = find(SelectFLSO(:,i)>0);
   if (length(pos)>0) 
       SparseSelectFLSO(SelectFLSO(pos,i),i) = ones(length(pos),1); 
   end
end
SparseSelectFLSO = sparse(SparseSelectFLSO);
spy(SparseSelectFLSO,'k',6)
axis('square')
title('Ritz vectors selected for orthogonalization')
ylabel('Selected Ritz Vectors')
xlabel('Lanczos Step')
disp('done with figure 9')
disp('pause (hit return to continue)'), pause
%
%  Produce figure of Ritz values selected for orthogonalization
%
figure(10)
hold off, clf
strcolor='b+w+r+g+';
for j=1:m
  len = length(find(SelectFLSO(:,j)>0));
  for jj = 1:len,
    Ritznumber = SelectFLSO(jj,j);
    color = Ritznumber;
    if (color>j/2), color = j+1-color; end
    remcolor = 2*rem(color,4)+1;
    str = strcolor(remcolor:remcolor+1);
    hndl=plot(j,EvalFLSO(Ritznumber,j),str);
    set(hndl,'MarkerSize',markersize);
    hold on
  end
end
% plot((m+1)*ones(size(e)),e,'k+')
axis([0,m+2,mine,maxe])
for b=steplabel, plot([b,b],[mine,maxe],'k:'); end
title('Ritz values whose vectors are selected for orthogonalization')
xlabel('Lanczos step'), ylabel('Ritz values')
