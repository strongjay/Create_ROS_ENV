#!/bin/bash
# ROS2 jazzy
NAME=ROS_Jazzy
./docker/ros2_jazzy/run.bash -g -n $NAME # -s /media/work/skt_data005 # -r -c _cuda11.2.2_ubuntu22.04
#   -g: 启用GPU支持
#   -r: 容器退出时自动删除
#   -n: 指定容器名称
#   -s: 共享文件夹路径
#   -c: 指定CUDA版本 
#   -w: 不使用host网络模式
