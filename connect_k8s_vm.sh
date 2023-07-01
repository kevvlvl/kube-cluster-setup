#!/usr/bin/bash

USER="kube"
CONTROL_PLANE=192.168.56.5
WORKER_NODE=192.168.56.6

if [ "$1" == "w" ]; then
   ssh $USER@$WORKER_NODE
elif [ "$1" == "c" ]; then
   ssh $USER@$CONTROL_PLANE
else
   echo "Expected one argument. c for control plane or w for worker node. Example: ./connect_k8s_vm.sh w to connect to the worker node"
fi
