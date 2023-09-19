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
elif [ "$1" == "connect" ]; then
    
    if [ "$2" == "ctrl" ]; then
        echo "About to connect to the control plane node at ${CONTROL_PLANE_IP}"
        ssh $USER@$CONTROL_PLANE_IP
    elif [ "$2" == "worker" ]; then
        echo "About to connect to the worker node at ${WORKER_IP}"
        ssh $USER@$WORKER_IP
    else
        echo "./cluster.sh connect ctrl|worker to connect to control plane node or worker node"
    fi

else
    echo "Expected one argument:"
    echo "cluster.sh up             Start the VMs"
    echo "cluster.sh halt           Shutdown the VMs"
    echo "cluster.sh info           Status info of VMs"
    echo "cluster.sh connect ctrl   Connect to the control plane node"
    echo "cluster.sh connect worker Connect to the worker node"
fi
