#!/bin/bash
script_dir="$(dirname $0)"
cd $script_dir

IMAGE_NAME=hrjp/ros2:humble
CONTAINER_NAME=ros2_humble
SHARE_FOLDER_PATH=""
SHARE_FOLDER_CMD=""
GPU_CMD=""
CONTAINER_NAME_CMD="--name $CONTAINER_NAME"
NETHOST_CMD="--net=host"
CREATE_NEW_CONTAINER=true

usage_exit() {
        echo " " 1>&2
        echo " -----------------------------------------------------------------------------" 1>&2
        echo " OPTIONS              | DETAILS " 1>&2
        echo " -----------------------------------------------------------------------------" 1>&2
        echo " -g                   | GPU enabled" 1>&2
        echo " -r                   | remove when exit the container" 1>&2
        echo " -n CONTAINER_NAME    | container name (default : $CONTAINER_NAME )" 1>&2
        echo " -s SHARE_FOLDER_PATH | directory path shared with the inside of the container" 1>&2
        echo " -c CUDA_VERSION      | use CUDA version (default : none, options: 12.4.1, 12.5.1, 12.6.3, 12.8.1, 12.9.1)" 1>&2
        echo " -w                   | not using --net=host" 1>&2
        echo " -h                   | show this help message" 1>&2
        echo " -----------------------------------------------------------------------------" 1>&2
        exit 1
}

while getopts grwn:s:c:h OPT
do
    case $OPT in
        g )  GPU_CMD="--gpus all"
            echo " Using nvidia GPUs" 1>&2
            ;;
        r )  REMOVE_CMD="--rm"
            CONTAINER_NAME_CMD=""
            CREATE_NEW_CONTAINER=true  # 使用--rm参数时总是创建新容器
            echo " Remove when exit this container" 1>&2
            ;;
        w )  NETHOST_CMD=""
            echo " Not using --net=host" 1>&2
            ;;
        n)  CONTAINER_NAME=$OPTARG
            CONTAINER_NAME_CMD="--name $CONTAINER_NAME"
            echo " CONTAINER_NAME = $OPTARG " 1>&2
            ;;
        s )  SHARE_FOLDER_PATH=$OPTARG
            SHARE_FOLDER_CMD="-v $SHARE_FOLDER_PATH:/home/share"
            echo " SHARE_FOLDER_PATH = $SHARE_FOLDER_PATH " 1>&2
            ;;
        c )  IMAGE_NAME="${IMAGE_NAME}_cuda${OPTARG}"
            echo " Using CUDA image: $IMAGE_NAME" 1>&2
            ;;
        h ) usage_exit
            ;;
        \? ) usage_exit
            ;;
    esac
done

# 如果没有指定--rm参数，则检查容器是否存在
if [ -z "$REMOVE_CMD" ]; then
    # 检查容器是否存在
    if [ "$(docker ps -aq -f name=^${CONTAINER_NAME}$)" ]; then
        # 容器存在，检查是否正在运行
        if [ "$(docker ps -q -f name=^${CONTAINER_NAME}$)" ]; then
            # 容器正在运行，直接进入容器
            echo "Container $CONTAINER_NAME is already running. Connecting to it..."
            xhost +
            docker exec -it $CONTAINER_NAME /bin/bash
            exit 0
        else
            # 容器存在但未运行，启动容器并进入
            echo "Starting existing container $CONTAINER_NAME..."
            xhost +
            docker start $CONTAINER_NAME
            docker exec -it $CONTAINER_NAME /bin/bash
            exit 0
        fi
    else
        # 容器不存在，需要创建新容器
        CREATE_NEW_CONTAINER=true
    fi
    
    # 为后续可能生成的快捷脚本做准备
    cd
    if [ ! -f $CONTAINER_NAME.bash ]; then
        touch $CONTAINER_NAME.bash
        sudo chmod 777 $CONTAINER_NAME.bash
        echo -e "xhost + \n docker start $CONTAINER_NAME \n docker exec -it $CONTAINER_NAME /bin/bash" >>$CONTAINER_NAME.bash
    fi
else
    CONTAINER_NAME=""
fi

# 如果需要创建新容器，则运行docker run命令
if [ "$CREATE_NEW_CONTAINER" = true ]; then
    xhost +
    
    docker run -it  $CONTAINER_NAME_CMD\
                -v /dev:/dev \
                -v /tmp/.X11-unix:/tmp/.X11-unix \
                -v $HOME/.Xauthority:/root/.Xauthority:rw \
                $SHARE_FOLDER_CMD \
                -e DISPLAY=$DISPLAY \
                -e QT_X11_NO_MITSHM=1 \
                $GPU_CMD \
                $REMOVE_CMD \
                $NETHOST_CMD \
                --privileged \
                $IMAGE_NAME /bin/bash
fi
