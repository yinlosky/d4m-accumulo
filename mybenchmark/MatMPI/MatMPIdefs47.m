global MPI_COMM_WORLD;
load 'MatMPI/MPI_COMM_WORLD.mat';
MPI_COMM_WORLD.rank = 47;
pRUN_Parallel_Wrapper;
