#!/usr/bin/bash

USER="kube"
WORKER_NODE=192.168.56.6

echo "About to connect to the worker node at ${WORKER_NODE}"
ssh $USER@$WORKER_NODE
