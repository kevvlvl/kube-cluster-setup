#!/usr/bin/bash

VBoxManage controlvm "kube-controlplane" acpipowerbutton
VBoxManage controlvm "kube-worker1" acpipowerbutton
