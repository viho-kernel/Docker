#!/bin/bash
set -eu
echo "=== Initial disk layout ==="
lsblk
# Install required package (RHEL uses dnf/yum)
dnf install -y cloud-utils-growpart || yum install -y cloud-utils-growpart

# Expand partition 4
growpart /dev/nvme0n1 4

echo "=== After growpart ==="
lsblk

# Resize physical volume
pvresize /dev/nvme0n1p4

# Show volume group free space
vgdisplay RootVG

# Extend /var to 20GB TOTAL
lvextend -L 30G /dev/RootVG/varVol

# Resize filesystem (RHEL uses XFS here)
xfs_growfs /var

echo "=== Final disk usage ==="
df -hT

# Remove old Docker/podman packages
dnf remove -y docker docker-client docker-client-latest docker-common \
             docker-latest docker-latest-logrotate docker-logrotate \
             docker-engine podman runc || true

# Update system
dnf update -y

# Install required plugin
dnf install -y dnf-plugins-core

# Add Docker repo
dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo

# Install Docker
dnf install -y docker-ce docker-ce-cli containerd.io \
               docker-buildx-plugin docker-compose-plugin

# Enable and start Docker
systemctl enable --now docker

# Add ec2-user to docker group
usermod -aG docker ec2-user

#check docker version
docker --version

