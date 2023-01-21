#!/bin/sh
# Copyright (c) 2018-present, Facebook, Inc.
# All rights reserved.
#
# This source code is licensed under the license found in the
# LICENSE file in the root directory of this source tree.

### conda activate poincare
export wd=$(pwd)/../

python3 embed.py \
       -dim 2 \
       -lr 0.005 \
       -epochs 1 \
       -batchsize 50 \
       -eval_each 1 \
       -negs 10 \
       -burnin 10 \
       -ndproc 16 \
       -manifold poincare \
       -dset LG/gene_connection.csv \
       -checkpoint LG/embedding.pth \
       -dampening 1.0 \
       -burnin_multiplier 0.2 \
       -neg_multiplier 0.5 \
       -fresh \
       -sparse \
       -quiet \
       -train_threads 16 \
       -sym  
