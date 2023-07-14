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

POD_NETWORK_CIDR="10.244.0.0/16"

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
    sudo ufw allow 6443/tcp
    sudo ufw allow 2379:2380/tcp
    sudo ufw allow 10250/tcp
    sudo ufw allow 10259/tcp
    sudo ufw allow 10257/tcp
}

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
    # TODO: Far from perfect, but using read to halt script so that user can perform manual action. Figure out sed line to search and modify subsequent matching line...

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

# Init the control plane

sudo kubeadm init \
    --apiserver-advertise-address=${CONTROL_PLANE_IP} \
    --pod-network-cidr=${POD_NETWORK_CIDR}

echo "Capture Token in the log output"
read token

# TODO: Far from perfect, but using read to halt script so that user can perform manual action.

# kubeadm join 192.168.56.5:6443 --token pw197i.mlw8wpbr2xsbqkwq \
# 	--discovery-token-ca-cert-hash sha256:74102cad9feaaf62a9c5ccc53a94bc5d1750659f839c511e8641886f14db8f88

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Transfer the admin kube config to the worker node
sudo scp /etc/kubernetes/admin.conf kube@${WORKER_IP}:/home/kube/.kube/config

# Install CNI Calico - supports network policies and ingress
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/tigera-operator.yaml

# Source of the CRD: https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/custom-resources.yaml
# Modify the IP CIDR to match the defined one at the top of the script.
cat <<EOT >> calico-crd.yaml
# This section includes base Calico installation configuration.
# For more information, see: https://projectcalico.docs.tigera.io/master/reference/installation/api#operator.tigera.io/v1.Installation
apiVersion: operator.tigera.io/v1
kind: Installation
metadata:
  name: default
spec:
  # Configures Calico networking.
  calicoNetwork:
    # Note: The ipPools section cannot be modified post-install.
    ipPools:
    - blockSize: 26
      cidr: $POD_NETWORK_CIDR
      encapsulation: VXLANCrossSubnet
      natOutgoing: Enabled
      nodeSelector: all()

---

# This section configures the Calico API server.
# For more information, see: https://projectcalico.docs.tigera.io/master/reference/installation/api#operator.tigera.io/v1.APIServer
apiVersion: operator.tigera.io/v1
kind: APIServer
metadata:
  name: default
spec: {}
EOT

kubectl create -f calico-crd.yaml

# Flannel - does not support network policies or ingress
#kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

kubectl get po --all-namespaces
