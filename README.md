# CTFd [Custom by Fr3Nky]

原版的README在这里阅读：[Official README](./README_CTFd.md)

## Custom在哪里

基于3.7.0版本的CTFd，修改了Dockerfile，进行了换源操作，更适合在中国大陆的网络环境下部署，添加了[CTFd-Whale](https://github.com/glzjin/CTFd-Whale)插件，更适合用来搭建动态靶机，修改了docker-compose.yml，配置好动态靶机所需插件的启动环境。

## 工作内容



## 如何快速启动

本地已有docker / docker compose / git 环境可以快速启动

```
git clone -b final_project https://github.com/FrenkyOHOHOH/CTFd-fr3nky.git --depth=1
git clone https://github.com/FrenkyOHOHOH/ctfd-whale CTFd-fr3nky/CTFd/plugins/ctfd-whale --depth=1
cd CTFd-fr3nky
docker swarm init
docker node update --label-add='name=linux-1' $(docker node ls -q)
docker compose up -d --build
docker compose exec ctfd python manage.py
```

