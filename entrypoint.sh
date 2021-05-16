#!/bin/bash

source activate

/chia-blockchain/venv/bin/chia init

if [[ -z "$1" ]]; then
    /bin/bash
else
    exec "$@"
fi
