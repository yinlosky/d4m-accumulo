#/usr/bin/env bash
cd /mnt/common/yhuang9/Yinigen
hdfs dfs -rmr lz_edge
hdfs dfs -mkdir lz_edge
hdfs dfs -put Heigen65546.edge lz_edge
cd /mnt/common/yhuang9/HEIGEN/
./run_heigen.sh 1048576 8 lz_edge makesym > heigen1048576.log2 2>&1
