#!/bin/bash

#
# This script is based on the official chia-docker project. I rewrite
# to better running under Serverless.
#
# Pre-Condition
#
#   1. Path need to be mount in docker:
#
#   * Secret Words Path: /config/secret_words  
#   * CA Keys file: /keys/ca
#   * Plots Temp: /plots-tmp
#   * Plots Final: /plots-final
#
#   If you already have your full node, you can find your CA keys file
#   under ~/.chia/mainnet/config/ssl/ca
#
#   2. Env in harvest model
#
#   * FARMER_IP
#   * FARMER_PORT
#

# Only for debug, change this to true
if [[ $2 = "dry-run" ]]; then
    echo "Running in dry run model..."
    cmd=echo
else
    cmd=''
fi

SECRET_WRODS_PATH="/config/secret_words"
CA_KEYS_PATH="/keys/ca"
FARMER_IP=${FARMER_IP:-127.0.0.1}
FARMER_PORT=${FARMER_PORT:-8447}

PLOTS_FINAL=${PLOTS_FINAL:-/plots-final}
PLOTS_TMP=${PLOSTS_TMP:-/plots-tmp}

export PATH=/chia-blockchain/venv/bin:$PATH

# Activate virtualenv for chia
$cmd . ./activate

# Init chia env
$cmd chia init

# Add Keys, Mount the secret words under SECRET_WRODS_PATH
if [[ -f $SECRET_WORDS_PATH ]]; then
    echo "Adding keys under $SECRET_WRODS_PATH..."
    $cmd chia keys add -f SECRET_WRODS_PATH
    echo "Adding keys succesfully"
fi

if [[ -z "$1" ]]; then
    /bin/bash
elif [ $1 = "all" ]; then
    echo "Starting all node..."
    $cmd chia start all
    $cmd tail -f ~/.chia/mainnet/log/debug.log
    echo "Start all node successfully"
elif [ $1 = "harvester" ]; then
    echo "Starting harvester and connect to $FARMER_IP:$FARMER_PORT..."
    # Only run harvester, CA keys under CA_KEYS_PATH
    if [[ ! -f $CA_KEYS_PATH ]]; then
        echo "ERROR: Can not find any keys under $CA_KEYS_PATH"
        exit 1
    fi
    $cmd sed -i 's/localhost/127.0.0.1/g' ~/.chia/mainnet/config/config.yaml
    $cmd sed -i 's/WARNING/INFO/g' ~/.chia/mainnet/config/config.yaml
    $cmd chia configure --set-farmer-peer $FARMER_IP:$FARMER_PORT
    $cmd chia start harvester
    $cmd tail -f ~/.chia/mainnet/log/debug.log
    echo "Start harvester successfully"
elif [ $1 = "create-plots-k32" ]; then
    echo "Creating plots..."
    $cmd chia create plots -t $PLOTS_TMP -d $PLOTS_FINAL
    echo "Start all node successfully"
else
    exec "$@"
fi
