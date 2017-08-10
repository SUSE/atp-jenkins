#! /bin/sh
# -*- shell-script -*-

set -o xtrace

zypper addrepo --check --gpgcheck --refresh obs://Virtualization:containers Virtualization:containers
zypper --gpg-auto-import-keys refresh
zypper --non-interactive install --from Virtualization:containers docker

systemctl enable docker.service
