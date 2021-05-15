#!/bin/bash

docker run -it \
  -d \
  --name chia-docker \
  -v ~/.chia:/root/.chia \
  -v ~/.local:/root/.local \
  -v /plots-tmp:/plots-tmp \
  -v /plots-final:/plots-final \
  chia-docker \
  chia plots create -t /plots-tmp -d /plots-final -b 2048
