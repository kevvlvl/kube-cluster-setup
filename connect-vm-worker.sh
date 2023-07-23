#!/usr/bin/bash

source kubeadm-vars.sh

echo "About to connect to the worker node at ${WORKER_IP}"
ssh $USER@$WORKER_IP
