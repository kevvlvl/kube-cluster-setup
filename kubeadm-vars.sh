HOSTNAME_FILE=/etc/hostname
HOSTS_FILE=/etc/hosts
FSTAB_FILE=/etc/fstab

# Gateway IP address
GATEWAY_IP="192.168.56.1"

# Control plane IP address
CONTROL_PLANE_IP="192.168.56.5"

# Control plane hostname
CONTROL_PLANE_NAME="kube-controlplane"

# Worker node IP address
WORKER_IP="192.168.56.6"

# Worker node hostname
WORKER_NAME="kube-worker1"

# Network interface to which we assign the static IP address of the VM
ETH_HOST_ADAPTER="enp0s8"

# Network CIDR pod IP assignment subnet
POD_NETWORK_CIDR="10.244.0.0/16"

# Virtualbox Ubuntu username
USER="kube"