#!/bin/bash

# Safer bash script
set -euxo pipefail

# If terminal is not already in pxe folder, change it so that it is during script runtime
if ! pwd | grep -q pxe; then
    pushd ./pxe
fi

# Create httpd directory structure
mkdir -p httpd/content/isos
mkdir -p httpd/content/roles/generic
mkdir -p httpd/content/roles/infra-dev-laptop
mkdir -p httpd/content/roles/storage

# Download Ubuntu 20 iso if it doesn't exist
if [ ! -f "ubuntu.iso" ]; then
  wget https://releases.ubuntu.com/20.04/ubuntu-20.04.2-live-server-amd64.iso -q --show-progress -O ubuntu.iso
fi

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