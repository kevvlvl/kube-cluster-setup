#!/usr/bin/bash

source kubeadm-vars.sh

if [ "$1" == "up" ]; then
    echo "Starting the two nodes in headless mode..."
    VBoxManage startvm $CONTROL_PLANE_NAME --type headless
    VBoxManage startvm $WORKER_NAME --type headless
elif [ "$1" == "halt" ]; then
    echo "Shutting down the two nodes (acpi power button)"
    VBoxManage controlvm $CONTROL_PLANE_NAME acpipowerbutton
    VBoxManage controlvm $WORKER_NAME acpipowerbutton
elif [ "$1" == "info" ]; then
    echo "List of VMs:"
    VBoxManage list vms
    echo "---------------------"
    echo "List of running VMs:"
    VBoxManage list runningvms
else
    echo "Expected one argument:"
    echo "cluster.sh up     Start the Virtualbox VMs"
    echo "cluster.sh halt   Stop te Virtualbox VMs using ACPI Powerbutton Shutdown"
    echo "cluster.sh info   Status of Virtualbox VMs"
fi
