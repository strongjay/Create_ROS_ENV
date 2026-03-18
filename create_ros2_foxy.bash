#!/bin/bash
script_dir="$(dirname $0)"
cd $script_dir

# ROS2 foxy
NAME=ROS_Foxy
./docker/ros2_foxy/run.bash -g -n $NAME # -s /media/work/skt_data005 # -r -c _cuda11.2.2_ubuntu20.04
#   -g: 启用GPU支持
#   -r: 容器退出时自动删除
#   -n: 指定容器名称
#   -s: 共享文件夹路径
#   -c: 指定CUDA版本 
#   -w: 不使用host网络模式
