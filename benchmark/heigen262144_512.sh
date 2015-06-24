#!/bin/bash
cd /mnt/common/yhuang9/MeasureTimeOfAccumuloAndD4M/benchmark
touch heigen262144_512.performance
printf 'COMMANDS: nohup ./run_heigen.sh 262144 8 h262144 makesym >> /mnt/common/yhuang9/MeasureTimeOfAccumuloAndD4M/benchmark/heigen262144_512.performance 2>&1 & \n' >> heigen262144_512.performance
cd /mnt/common/yhuang9/HEIGEN/
nohup ./run_heigen.sh 262144 8 h262144 makesym >> /mnt/common/yhuang9/MeasureTimeOfAccumuloAndD4M/benchmark/heigen262144_512.performance 2>&1 &
