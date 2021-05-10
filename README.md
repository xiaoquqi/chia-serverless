# How to Build?

## General

This project is based on chia-docker project, but remove entrypoints.sh commands. The purpose of this project is to run chia in serverless. You can pull the docker here:

```
docker pull registry.cn-beijing.aliyuncs.com/ray-dockers/chia-docker:latest
```

## Replace github with local mirror

```
docker build -t chia-docker --build-arg BRANCH=latest --build-arg GIT_MIRROR=https://e.coding.net/xiaoquqi/github .
```
