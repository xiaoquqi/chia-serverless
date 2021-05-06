#!/bin/bash

source activate
export PATH=/chia-blockchain/venv/bin:$PATH

if [[ -z "$1" ]]; then
    /bin/bash
else
    exec "$@"
fi
