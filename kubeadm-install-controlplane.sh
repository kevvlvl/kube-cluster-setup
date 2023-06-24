#!/usr/bin/bash

HOSTNAME_FILE=/etc/hostname
HOSTS_FILE=/etc/hosts
FSTAB_FILE=/etc/fstab

GATEWAY_IP="192.168.56.1"

CONTROL_PLANE_IP="192.168.56.5"
CONTROL_PLANE_NAME="kube-controlplane"
WORKER_IP="192.168.56.6"
WORKER_NAME="kube-worker1"

ETH_HOST_ADAPTER="enp0s8"

# Set hostname to kube-controlplane
sudo hostnamectl set-hostname ${CONTROL_PLANE_NAME}
echo "New Hostname set"
cat $HOSTNAME_FILE

# Assign static IP for the control plane
sudo nmcli con add type ethernet con-name 'static' ifname $ETH_HOST_ADAPTER ipv4.method manual ipv4.addresses $CONTROL_PLANE_IP/24 gw4 $GATEWAY_IP
sudo nmcli con mod static ipv4.dns $GATEWAY_IP
sudo nmcli con up id 'static'

echo "Static IP Set"
ip addr

# Add static IPs of the control plane and worker node to the hosts file for name resolution
echo "${CONTROL_PLANE_IP} ${CONTROL_PLANE_NAME}" | sudo tee -a $HOSTS_FILE
echo "${WORKER_IP} ${WORKER_NAME}" | sudo tee -a $HOSTS_FILE

echo "Updated hosts file"
cat $HOSTS_FILE

# Disable swap temporarily
sudo swapoff -a

# Remove the swap permanently
sudo sed -e '/swap/ s/^#*/#/' -i $FSTAB_FILE

# Install containerd (from the Docker documentation: https://docs.docker.com/engine/install/ubuntu/)

sudo apt-get update && sudo apt-get install -y \
    ca-certificates \
    curl gnupg

sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update && sudo apt-get install -y containerd.io

# Install kubeadm

# Install CNI flannel

# Print keys for worker nodes to join