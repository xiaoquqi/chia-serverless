#!/bin/bash

#
# This script is based on the official chia-docker project. I rewrite
# to better running under Serverless.
#
# Pre-Condition
#
#   1. Path need to be mount in docker:
#
#   * Secret Words Path: /conf/secret_words  
#   * CA Keys file: /conf/ca_keys
#   * Plots Temp: /plots-tmp
#   * Plots Final: /plots-final
#
#   * Aliyun ossutil config: /conf/ossutilconfig
#
#   If you already have your full node, you can find your CA keys file
#   under ~/.chia/mainnet/config/ssl/ca
#
#   2. Env in harvest model
#
#   * FARMER_IP
#   * FARMER_PORT
#
#   3. Create plots and upload to oss
#
#   * BUCKET

# Only for debug, change this to true
if [[ $2 = "dry-run" ]]; then
    echo "Running in dry run model..."
    cmd=echo
else
    cmd=''
fi

# For chia
SECRET_WORDS_PATH="/conf/secret_words"
CA_KEYS_PATH="/conf/ca_keys"
FARMER_IP=${FARMER_IP:-127.0.0.1}
FARMER_PORT=${FARMER_PORT:-8444}

PLOTS_FINAL=${PLOTS_FINAL:-/plots-final}
PLOTS_TMP=${PLOSTS_TMP:-/plots-tmp}

# For Aliyun oss configs
OSSUTIL_CONFIG="/conf/ossutilconfig"

# oss bucket name should be unique in global
# so create bucket before this scripts run
BUCKET=${BUCKET}

export PATH=/chia-blockchain/venv/bin:$PATH

# Activate virtualenv for chia
$cmd . /chia-blockchain/activate

# Init chia env
$cmd chia init

# Add Keys, Mount the secret words under SECRET_WORDS_PATH
if [[ -f $SECRET_WORDS_PATH ]]; then
    echo "Adding keys under $SECRET_WORDS_PATH..."
    $cmd chia keys add -f $SECRET_WORDS_PATH
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
    if [[ ! -d $CA_KEYS_PATH ]]; then
        echo "ERROR: Can not find any keys under $CA_KEYS_PATH"
        exit 1
    fi
    $cmd sed -i 's/localhost/127.0.0.1/g' ~/.chia/mainnet/config/config.yaml
    $cmd sed -i 's/WARNING/INFO/g' ~/.chia/mainnet/config/config.yaml
    $cmd chia configure --set-farmer-peer $FARMER_IP:$FARMER_PORT
    $cmd chia plots add -d $PLOTS_FINAL
    $cmd chia start harvester
    $cmd tail -f ~/.chia/mainnet/log/debug.log
    echo "Start harvester successfully"
elif [ $1 = "create-plots-k32" ]; then
    TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
    PLOTS_FINAL="$PLOTS_FINAL/${TIMESTAMP}_${RANDOM}"
    mkdir -p $PLOTS_FINAL

    $cmd ossutil64 ls -c $OSSUTIL_CONFIG oss://$BUCKET
    if [[ $? != 0 ]]; then
        echo "Target bucket $BUCKET not found, please create the bucket first."
	exit 1
    fi

    echo "Creating plots, tmp path is $PLOTS_TMP, final path: $PLOTS_FINAL..."
    $cmd chia plots create -t $PLOTS_TMP -d $PLOTS_FINAL
    echo "Plot create succesfully"

    echo "Uploading plot file to bucket $BUCKET..."
    $cmd ossutil64 -c $OSSUTIL_CONFIG cp $PLOTS_FINAL/*.plot oss://$BUCKET -u
    if [[ $? != 0 ]]; then
        echo "Upload plot file to bucket $BUCKET failed."
    else
        echo "Removing final dir $PLOTS_FINAL..."
	#$cmd rm -rf $PLOTS_FINAL
    fi
    echo "Upload plot file to bucket $BUCKET succesfully"
else
    exec "$@"
fi
