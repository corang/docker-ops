#!/bin/bash

# Safer bash script
set -euxo pipefail

# Download and install script dependencies
sudo apt install apt-rdepends -y

# If terminal is not already in pxe folder, change it so that it is during script runtime
if ! pwd | grep -q pxe; then
    pushd ./pxe
fi

# Create httpd directory structure
mkdir -p httpd/content/isos
mkdir -p httpd/content/roles/generic
mkdir -p httpd/content/roles/infra-dev-laptop
mkdir -p httpd/content/roles/storage
mkdir -p httpd/content/packages

# Download Ubuntu 20 iso if it doesn't exist
if [ ! -f "ubuntu.iso" ]; then
  wget https://releases.ubuntu.com/20.04/ubuntu-20.04.2-live-server-amd64.iso -q --show-progress -O ubuntu.iso
fi

# Download and archive NetworkManager and dependencies
if [ ! -f "networkManager.tar.gz" ]; then
  mkdir -p nm_temp
  pushd nm_temp
  apt-get download $(apt-rdepends network-manager|grep -v "^ " |grep -v "^debconf-2.0$" | grep -v "^time-daemon$")
  tar -cvzf ../networkManager.tar.gz ./
  popd
  rm -rf nm_temp
fi

# Copy NetworkManager archive to apache packages directory
cp -p ./networkManager.tar.gz ./httpd/content/packages

# Copy httpd conf to apache base directory
cp -p ./pxe-conf/httpd.conf ./httpd/httpd.conf

# Copy Ubuntu iso to apache content directory
cp -p ./ubuntu.iso httpd/content/isos/ubuntu20.iso

# Copy roles and scripts to apache directory
cp -p ./pxe-conf/role-generic.yml ./httpd/content/roles/generic/user-data
cp -p ./pxe-conf/role-infra-dev.yml ./httpd/content/roles/infra-dev-laptop/user-data
cp -p ./pxe-conf/role-storage.yml ./httpd/content/roles/storage/user-data
cp -p ./pxe-conf/infra-dev-provision-script.sh ./httpd/content/roles/infra-dev-laptop/script.sh

# Create meta-data files for ubuntu autoinstall
touch ./httpd/content/roles/generic/meta-data
touch ./httpd/content/roles/infra-dev-laptop/meta-data
touch ./httpd/content/roles/storage/meta-data

# Go back to original directory
popd &> /dev/null