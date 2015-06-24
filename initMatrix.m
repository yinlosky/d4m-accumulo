function initMatrix(NumOfMachines,NumOfProcessors,Scale,EdgesPerVertex)
%%
%%  This function will generate a input matrix with the size of 2^Scale and stored in 
%%  an accumulo table named M{2^Scale}.
%%  Note: 1. This will generate a corresponding HEIGEN edge file 
%%  Note: 2. The M{2^Scale} is symmetric
myDB;

root = matlabroot;
fname = ('benchmark/benchmarking.log');
fstat = fopen(fname,'a+');
StartTime = datestr(now);

fwrite(fstat,['***********************************************' sprintf('\n') 'Bluewave Initializing the input matrix, start time: ' StartTime sprintf('\n*******************************************')]);
fwrite(fstat,['**Commands:  initMatrix( ' num2str(NumOfMachines) ',' num2str(NumOfProcessors) ',' num2str(Scale) ','  num2str(EdgesPerVertex) ')' ]);


NumOfNodes = 2^Scale;
initM_scale = DB('Scale');
initM_numofm = DB('numofm');
initM_edges = DB('edges');

initM_matrix = DB(['M' num2str(NumOfNodes) '_' num2str(EdgesPerVertex)]);
delete(initM_matrix);
initM_matrix = DB(['M' num2str(NumOfNodes) '_' num2str(EdgesPerVertex)]);

put(initM_scale,Assoc('1,','1,',sprintf('%d,',Scale)));
put(initM_numofm,Assoc('1,','1,',sprintf('%d,',NumOfMachines)));
put(initM_edges,Assoc('1,','1,',sprintf('%d,',EdgesPerVertex)));

  switch NumOfMachines
         case 1
                machines={'n117'};
         case 2
		machines={'n117' 'n118'};
         case 3
		machines={'n117' 'n118' 'n119'};
         case 4
		machines={'n117' 'n118' 'n119' 'n120'};
         case 5
		machines={'n117' 'n118' 'n119' 'n120' 'n121'};
         case 6
		machines={'n117' 'n118' 'n119' 'n120' 'n121' 'n122'};
         case 7
		machines={'n117' 'n118' 'n119' 'n120' 'n121' 'n122' 'n123'};
         case 8
		machines={'n117' 'n118' 'n119' 'n120' 'n121' 'n122' 'n123' 'n124'};
         case 9
		machines={'n117' 'n118' 'n119' 'n120' 'n121' 'n122' 'n123' 'n124' 'n125'};
         case 10
		machines={'n117' 'n118' 'n119' 'n120' 'n121' 'n122' 'n123' 'n124' 'n125' 'n126'};
        case 11
		machines={'n117' 'n118' 'n119' 'n120' 'n121' 'n122' 'n123' 'n124' 'n125' 'n126' 'n127'};
        case 12
		machines={'n117' 'n118' 'n119' 'n120' 'n121' 'n122' 'n123' 'n124' 'n125' 'n126' 'n127' 'n128'};
        case 13
                machines={'n117' 'n118' 'n119' 'n120' 'n121' 'n122' 'n123' 'n124' 'n125' 'n126' 'n127' 'n128' 'n129'};
	case 14
		machines={'n117' 'n118' 'n119' 'n120' 'n121' 'n122' 'n123' 'n124' 'n125' 'n126' 'n127' 'n128' 'n129' 'n130'};
	case 15
		machines={'n117' 'n118' 'n119' 'n120' 'n121' 'n122' 'n123' 'n124' 'n125' 'n126' 'n127' 'n128' 'n129' 'n130' 'n131'};
	case 16
		machines={'n117' 'n118' 'n119' 'n120' 'n121' 'n122' 'n123' 'n124' 'n125' 'n126' 'n127' 'n128' 'n129' 'n130' 'n131' 'n132'};
	end

tic;
disp(['Now initializing the input matrix in ' 'M' num2str(NumOfNodes)]);
disp(['Machines are' machines]);
eval(pRUN('SaveGraphData',NumOfProcessors,machines));
total_time = toc;

disp(['Total time to initialize M' num2str(NumOfNodes) ' is ' num2str(total_time)]);
endTime = datestr(now);

fwrite(fstat,['***********************************************' sprintf('\n') 'Initializing the input matrix, end time: ' endTime sprintf('\n*******************************************')]);

