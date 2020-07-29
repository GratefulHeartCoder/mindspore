#!/bin/bash
# Copyright 2020 Huawei Technologies Co., Ltd
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ============================================================================
 
echo "=============================================================================================================="
echo "Please run the scipt as: "
echo "bash run_distribute_train.sh MINDSPORE_HCCL_CONFIG_PATH DATA_PATH"
echo "for example: bash run_distribute_train.sh  MINDSPORE_HCCL_CONFIG_PATH DATA_PATH [PRETRAINED_CKPT_PATH](option)"
echo "It is better to use absolute path."
echo "=============================================================================================================="
 
DATA_DIR=$2
 
export MINDSPORE_HCCL_CONFIG_PATH=$1
export RANK_TABLE_FILE=$1
export RANK_SIZE=8
export DEVICE_NUM=8
PATH_CHECKPOINT=""
if [ $# == 3 ]
then
	PATH_CHECKPOINT=$3
fi
cores=`cat /proc/cpuinfo|grep "processor" |wc -l`
echo "the number of logical core" $cores
avg_core_per_rank=`expr $cores \/ $RANK_SIZE`
core_gap=`expr $avg_core_per_rank \- 1`
echo "avg_core_per_rank" $avg_core_per_rank
echo "core_gap" $core_gap
export SERVER_ID=0
rank_start=$((DEVICE_NUM * SERVER_ID))
for((i=0;i<DEVICE_NUM;i++))
do
    start=`expr $i \* $avg_core_per_rank`
    export DEVICE_ID=$i
    export RANK_ID=$((rank_start + i))
    export DEPLOY_MODE=0
    export GE_USE_STATIC_MEMORY=1
    end=`expr $start \+ $core_gap`
    cmdopt=$start"-"$end
 
    rm -rf LOG$i
    mkdir ./LOG$i
    cp  *.py ./LOG$i
    cd ./LOG$i || exit
    echo "start training for rank $i, device $DEVICE_ID"
    mkdir -p ms_log
    CUR_DIR=`pwd`
    export GLOG_log_dir=${CUR_DIR}/ms_log
    export GLOG_logtostderr=0
    env > env.log
    taskset -c $cmdopt python ../train.py  \
    --distribute="true" \
    --device_id=$DEVICE_ID \
    --checkpoint_url=$PATH_CHECKPOINT \
    --data_url=$DATA_DIR > log.txt 2>&1 &
    cd ../
done