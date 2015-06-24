NumOfProcessors =2;
  eval(pRUN('parallel_so_rrtv',NumOfProcessors,{})); %% times 'so_rpath' with 'scalar_rtv' and store in 'so_rrtv'
                eval(pRUN('parallel_so_updatev',NumOfProcessors,{}));
