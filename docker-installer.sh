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
