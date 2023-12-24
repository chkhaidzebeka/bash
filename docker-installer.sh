#!/bin/bash

#set -e

if [[ $EUID -ne 0 ]]; then
        echo "run as root" >&2
        exit 2
fi

FILE_NAME=$(mktemp)

function on_exit {
        rm $FILE_NAME
}

trap on_exit EXIT


wget https://releases.rancher.com/install-docker/20.10.sh -O $FILE_NAME
sh $FILE_NAME
sudo apt  install docker.io -y
sudo systemctl start docker
sudo systemctl enable docker

sudo addgroup wheel
sudo usermod -aG wheel $USER
sudo usermod -aG docker $USER
sudo chmod 777 /var/run/docker.sock

# Install k8s
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
curl -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl version --client


# Install help
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

# install rke
curl -s https://api.github.com/repos/rancher/rke/releases/latest | grep download_url | grep amd64 | cut -d '"' -f 4 | wget -qi - 
chmod +x rke_linux-amd64 
sudo mv rke_linux-amd64 /usr/local/bin/rke 
rke --version
