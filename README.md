# CTFd [Custom by Fr3Nky]

原版的README在这里阅读：[Official README](./README_CTFd.md)

之前搭的CTFd版本太旧了，写ctfd-whale动态靶机的[zhaojin](https://github.com/glzjin/CTFd-Whale)师傅也很久没有更新插件了，发现另一位 [frankli0324](https://github.com/frankli0324/ctfd-whale)师傅还在维护这个插件，遂更新靶场，给学校的实验室放复现题目和比赛日常用，也顺便做一些修改给自己当做自己毕设的base

## Custom在哪里了

基于3.7.0版本的[CTFd](https://github.com/CTFd/CTFd)定制，修改了Dockerfile，进行了换源操作，更适合在中国大陆的网络环境下部署，添加了[CTFd-Whale](https://github.com/FrenkyOHOHOH/ctfd-whale)插件，更适合用来搭建动态靶机，修改了docker-compose.yml，配置了动态靶机所需插件的启动环境，可以通过docker compose一键部署，以及针对Web题型和纯ip部署进行了一些优化，避免了繁琐的配置，当然也可以参照下面教程来手动配置

### 太长不看（快速部署）

本地已有docker / docker compose / git 环境可以快速启动，使用下面的指令快速启动

```shell
(curl -fsSL -m180 https://raw.githubusercontent.com/FrenkyOHOHOH/CTFd-fr3nky/final_project/deploy.sh || wget -q -T180 https://raw.githubusercontent.com/FrenkyOHOHOH/CTFd-fr3nky/final_project/deploy.sh) | bash
```

运行 deploy.sh ，若检测到缺少环境，脚本会停止运行，不会改变您机器的环境，请您自己配置环境，若环境齐全，则会自动安装 CTFd-fr3nky ，所有配置使用默认的配置，若需要自定义配置请使用**手动安装**

**无论使用哪种安装方式，请配置记得到管理面板配置ctfd-whale，如何配置在[本文末](#ctfd-whale配置)**

## 如何部署

建议在linux环境下部署，笔者只在ubuntu22的环境下进行了测试，确定了以下部署流程是没有问题的

### 配置环境

首先确定你的机器上有docker / docker compose / git环境，没有的话先配置环境

#### 本人环境

**仅供参考**

![image-20240322014900127](https://raw.githubusercontent.com/FrenkyOHOHOH/mdpic/main/img/image-20240322014900127.png)

```shell
$ git version
git version 2.34.1

$ docker version
Client: Docker Engine - Community
 Version:           26.0.0
 API version:       1.45
 Go version:        go1.21.8
 Git commit:        2ae903e
 Built:             Wed Mar 20 15:17:48 2024
 OS/Arch:           linux/amd64
 Context:           default

Server: Docker Engine - Community
 Engine:
  Version:          26.0.0
  API version:      1.45 (minimum version 1.24)
  Go version:       go1.21.8
  Git commit:       8b79278
  Built:            Wed Mar 20 15:17:48 2024
  OS/Arch:          linux/amd64
  Experimental:     false
 containerd:
  Version:          1.6.28
  GitCommit:        ae07eda36dd25f8a1b98dfbf587313b99c0190bb
 runc:
  Version:          1.1.12
  GitCommit:        v1.1.12-0-g51d5e94
 docker-init:
  Version:          0.19.0
  GitCommit:        de40ad0
  
$ docker compose version
Docker Compose version v2.25.0
```

#### Git

```shell
sudo apt update
sudo apt install git
```

#### Docker

以ubuntu系统举例，其他系统可以参照官方文档 https://docs.docker.com/engine/install/

**如果安装过旧版**

```shell
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done
```

**安装Docker**

```shell
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
```

使用apt包管理器安装最新版docker，包含了docker compose

```shell
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

验证docker安装成功

```shell
sudo docker run hello-world
```

### 手动安装

```shell
git clone https://github.com/FrenkyOHOHOH/CTFd-fr3nky.git
cd CTFd-fr3nky
git submodule update --init
```

若后续操作中若文件没有指出目录，就以 /CTFd-fr3nky 做根目录

#### docker-compose.yml

可以在这个文件下自定义题目映射端口

```yaml
  frps:
    image: glzjin/frp
    restart: always
    volumes:
      - ./conf/frp:/conf
    entrypoint:
      - /usr/local/bin/frps
      - -c
      - /conf/frps.ini
    ports:
      - 10000-10100:10000-10100  # 映射direct类型题目的端口
      - 8080:8080  # 映射http类型题目的端口
    networks:
      default:
      frp_connect:
        ipv4_address: 172.1.0.3
```

#### conf/frp/frpc.ini

自定义token，要和frps.ini的token一样

```ini
[common]
token = your_token
server_addr = 172.1.0.3
server_port = 7000
admin_addr = 172.1.0.4
admin_port = 7400
```

#### conf/frp/frps.ini

自定义域名、http映射的端口和token，要和frpc.ini的token一样

```ini
[common]
bind_port = 7000
vhost_http_port = 8080
token = your_token
subdomain_host = example.com
```

#### Dockerfile

自定义是否使用镜像加速

```dockerfile
...

# 针对中国大陆的网络环境换源，若网络出口不在中国大陆可以注释掉下面一行加速
RUN sed -i "s@http://deb.debian.org@http://mirrors.aliyun.com@g" /etc/apt/sources.list.d/debian.sources

...

# 针对中国大陆的网络环境换源，若网络出口不在中国大陆可以把 `-i` 以及后面的内容去掉
RUN pip install --no-cache-dir -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple --trusted-host pypi.tuna.tsinghua.edu.cn \
    && for d in CTFd/plugins/*; do \
        if [ -f "$d/requirements.txt" ]; then \
            pip install --no-cache-dir -r "$d/requirements.txt" -i https://pypi.tuna.tsinghua.edu.cn/simple --trusted-host pypi.tuna.tsinghua.edu.cn;\
        fi; \
    done;
    
...

# 针对中国大陆的网络环境换源，若网络出口不在中国大陆可以注释掉下面一行加速
RUN sed -i "s@http://deb.debian.org@http://mirrors.aliyun.com@g" /etc/apt/sources.list.d/debian.sources

...
```

#### 安装CTFd

```shell
docker swarm leave --force
docker swarm init
docker node update --label-add='name=linux-1' $(docker node ls -q)
docker compose up -d --build
```

这一步做完进去配置你的CTFd选项

### ctfd-whale配置

无论是哪种模式安装完成之后都要进去CTFd的管理面板填信息

![image-20240322030852841](https://raw.githubusercontent.com/FrenkyOHOHOH/mdpic/main/img/image-20240322030852841.png)

```shell
$ docker network ls
NETWORK ID     NAME                         DRIVER    SCOPE
f7db7a3454f5   bridge                       bridge    local
856db6a8062b   ctfd-fr3nky_default          bridge    local
qtuzdq8310xi   ctfd-fr3nky_frp_connect      overlay   swarm
s3xtkbu9u6b1   ctfd-fr3nky_frp_containers   overlay   swarm
bfc6d16f2a04   ctfd-fr3nky_internal         bridge    local
0724fb1f9993   docker_gwbridge              bridge    local
9a029a33f175   host                         host      local
hfxgg36zgef9   ingress                      overlay   swarm
a71b7dd14f6b   none                         null      local
```

![image-20240322030536599](https://raw.githubusercontent.com/FrenkyOHOHOH/mdpic/main/img/image-20240322030536599.png)

### 新建测试题目

进入CTFd管理面板

![image-20240322030955816](https://raw.githubusercontent.com/FrenkyOHOHOH/mdpic/main/img/image-20240322030955816.png)

新建题目，点Create之后记得选择题目状态（可见/不可见），测试镜像`ctftraining/qwb_2019_supersqli`

![image-20240322031439685](https://raw.githubusercontent.com/FrenkyOHOHOH/mdpic/main/img/image-20240322031439685.png)

最终效果

![image-20240322031614273](https://raw.githubusercontent.com/FrenkyOHOHOH/mdpic/main/img/image-20240322031614273.png)