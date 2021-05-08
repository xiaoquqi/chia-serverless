# How to Build?

## General

This project is based on chia-docker project, but remove entrypoints.sh commands.

## Replace github with local mirror

```
docker build -t chia-docker --build-arg BRANCH=latest --build-arg GIT_MIRROR=https://e.coding.net/xiaoquqi/github .
```
