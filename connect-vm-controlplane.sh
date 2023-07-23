#!/usr/bin/bash

source kubeadm-vars.sh

echo "About to connect to the control plane node at ${CONTROL_PLANE_IP}"
ssh $USER@$CONTROL_PLANE_IP
