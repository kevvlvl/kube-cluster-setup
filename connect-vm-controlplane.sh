#!/usr/bin/bash

USER="kube"
CONTROLPLANE_NODE=192.168.56.5

echo "About to connect to the control plane node at ${CONTROLPLANE_NODE}"
ssh $USER@$CONTROLPLANE_NODE
