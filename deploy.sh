#!/bin/bash

# 初始化计数器
found_count=0

# 检查docker、docker-compose（作为docker的子命令）和git命令是否存在
commands=("docker" "docker compose" "git")

for cmd in "${commands[@]}"; do
    if [[ $cmd == "docker compose" ]]; then
        # 检查docker-compose作为docker的子命令是否存在
        if docker compose version &> /dev/null; then
            echo "$cmd: yes"
            ((found_count++))
        else
            echo "$cmd: no"
        fi
    else
        # 检查其他命令是否存在
        if command -v "$cmd" &> /dev/null; then
            echo "$cmd: yes"
            ((found_count++))
        else
            echo "$cmd: no"
        fi
    fi
done

# 如果所有命令都找到了，安装靶场，否则提示
if [ $found_count -eq ${#commands[@]} ]; then
    echo "[+] 开始安装 CTFd-fr3nky"
    git clone https://github.com/FrenkyOHOHOH/CTFd-fr3nky.git --depth=1
    cd CTFd-fr3nky
    git submodule update --init
    docker swarm leave --force
    docker swarm init
    docker node update --label-add='name=linux-1' $(docker node ls -q)
    docker compose up -d --build
else
    echo "[-] 您缺少了运行需要的环境,请检查并安装需要的环境"
fi


