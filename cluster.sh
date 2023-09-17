#!/usr/bin/bash

source kubeadm-vars.sh

if [ "$1" == "start" ]; then
    echo "Starting the two nodes"
    virsh start $CONTROL_PLANE_NAME
    virsh start $WORKER_NAME
elif [ "$1" == "stop" ]; then
    echo "Shutting down the two nodes"
    virsh shutdown $CONTROL_PLANE_NAME
    virsh shutdown $WORKER_NAME
elif [ "$1" == "info" ]; then
    echo "VM status:"
    virsh list --all
else
    echo "Expected one argument:"
    echo "cluster.sh start  Start the kvm VMs"
    echo "cluster.sh stop   Stop the kvm VMs using ACPI Powerbutton Shutdown"
    echo "cluster.sh info   Status of kvm VMs"
fi
