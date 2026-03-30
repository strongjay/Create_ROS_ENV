#!/bin/bash
script_dir="$(dirname $0)"
cd $script_dir

# ROS1 melodic
NAME=ROS_Melodic_NoGPU    
./docker/ros_melodic/run_no_gpu.bash -n $NAME -s /media/work/PROGRAM 
#   -r: 容器退出时自动删除
#   -n: 指定容器名称
#   -s: 共享文件夹路径
#   -w: 不使用host网络模式

