#!/bin/bash

source activate
export PATH=/chia-blockchain/venv/bin:$PATH

/chia-blockchain/venv/bin/chia init

if [[ -z "$1" ]]; then
    /bin/bash
else
    exec "$@"
fi
