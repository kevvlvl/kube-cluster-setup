#!/usr/bin/bash

source kubeadm-vars.sh

if [ "$1" == "up" ]; then
    echo "Starting the two nodes"
    virsh start $CONTROL_PLANE_NAME
    virsh start $WORKER_NAME
elif [ "$1" == "halt" ]; then
    echo "Shutting down the two nodes"
    virsh shutdown $CONTROL_PLANE_NAME
    virsh shutdown $WORKER_NAME
elif [ "$1" == "info" ]; then
    echo "VM status:"
    virsh list --all
else
    echo "Expected one argument:"
    echo "cluster.sh up     Start the VMs"
    echo "cluster.sh halt   Shutdown the VMs"
    echo "cluster.sh info   Status info of VMs"
fi
