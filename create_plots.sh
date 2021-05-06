#!/bin/bash

docker run -it \
  --name chia-docker \
  -v ~/.chia:/root/.chia \
  -v /chia_tmp:/plots-tmp \
  -v /chia_data:/plots-final \
  -v ~/.local:/root/.local \
  chia-docker \
  chia plots create -t /plots-tmp -d /plots-final -b 2048
