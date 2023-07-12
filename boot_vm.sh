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
else
    echo "Expected one argument. up to start the VMs. halt to stop the VMs (ACPI Power button). Example: ./boot_vm.sh up to start the VMs"
fi
