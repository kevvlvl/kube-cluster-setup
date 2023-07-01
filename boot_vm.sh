#!/usr/bin/bash

VBoxManage startvm "kube-controlplane" --type headless
VBoxManage startvm "kube-worker1" --type headless
