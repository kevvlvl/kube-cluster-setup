#!/usr/bin/bash

VM_CONTROL_PLANE="kube-controlplane"
VM_WORKER_NODE="kube-worker1"

if [ "$1" == "up" ]; then
    echo "Starting the two nodes in headless mode..."
    VBoxManage startvm $VM_CONTROL_PLANE --type headless
    VBoxManage startvm $VM_WORKER_NODE --type headless
elif [ "$1" == "halt" ]; then
    echo "Shutting down the two nodes (acpi power button)"
    VBoxManage controlvm $VM_CONTROL_PLANE acpipowerbutton
    VBoxManage controlvm $VM_WORKER_NODE acpipowerbutton
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
