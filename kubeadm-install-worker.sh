#!/usr/bin/bash

source kubeadm-vars.sh

# Install OpenSSH to navigate between the VMs
{
    sudo apt-get update && sudo apt install -y \
        openssh-server \
        openssh-client

    systemctl status ssh.service

    sudo ufw allow ssh
    sudo ufw enable
    sudo ufw status
}

# Open k8s control plane required ports: https://kubernetes.io/docs/reference/networking/ports-and-protocols/
{
    sudo ufw allow 10250/tcp
    sudo ufw allow 30000:32767/tcp
    sudo ufw status
}

# Open Calico required ports: https://docs.tigera.io/calico/latest/getting-started/kubernetes/requirements
{
    sudo ufw allow 179/tcp
    sudo ufw allow 4789/tcp
    sudo ufw allow 4789/udp
    sudo ufw allow 5473/tcp
    sudo ufw allow 51820/udp
    sudo ufw allow 51821/udp
}

# Set hostname to kube-worker1
sudo hostnamectl set-hostname ${WORKER_NAME}
echo "New Hostname set"
cat $HOSTNAME_FILE

# Assign static IP for the worker node
sudo nmcli con add type ethernet con-name 'static' ifname $ETH_HOST_ADAPTER ipv4.method manual ipv4.addresses $WORKER_IP/24 gw4 $GATEWAY_IP
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

## IPv4 Forwarding iptables rules (from kubernetes.io doc: https://kubernetes.io/docs/setup/production-environment/container-runtimes/#forwarding-ipv4-and-letting-iptables-see-bridged-traffic)

{
    cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
    overlay
    br_netfilter
EOF

    sudo modprobe overlay
    sudo modprobe br_netfilter

    # sysctl params required by setup, params persist across reboots
    cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
    net.bridge.bridge-nf-call-iptables  = 1
    net.bridge.bridge-nf-call-ip6tables = 1
    net.ipv4.ip_forward                 = 1
EOF

    # Apply sysctl params without reboot
    sudo sysctl --system

    lsmod | grep br_netfilter
    lsmod | grep overlay

    sysctl net.bridge.bridge-nf-call-iptables net.bridge.bridge-nf-call-ip6tables net.ipv4.ip_forward
}

# Install containerd (from the Docker documentation: https://docs.docker.com/engine/install/ubuntu/)

{
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

    sudo systemctl stop containerd.service

    containerd config default | sudo tee -a /etc/containerd/config.toml
    sudo cat /etc/containerd/config.toml
    echo "Search for the line 'plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options' in the containerd config.toml and set the following SystemdCgroup to true"
    read pause
    sudo systemctl start containerd.service
}

# Install kubeadm

{
    sudo apt-get update && sudo apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl

    curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-archive-keyring.gpg

    echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

    sudo apt-get update && sudo apt-get install -y \
        kubelet \
        kubeadm \
        kubectl
    sudo apt-mark hold kubelet kubeadm kubectl
}

# Join the control plane using the join command with the token captured from the kubeadm-install-controlplane.sh procedure
### IMPORTANT. Ensure token and ca-cert-hash are the same values as displayed when initializing control plane cluster

kubeadm join ${CONTROL_PLANE_IP}:6443 --token pw197i.mlw8wpbr2xsbqkwq \
	--discovery-token-ca-cert-hash sha256:74102cad9feaaf62a9c5ccc53a94bc5d1750659f839c511e8641886f14db8f88

echo "Run kubectl get no -o wide on the control plane node to confirm readiness state of this worker node"
