#! /bin/sh
# -*- shell-script -*-

set -o xtrace

zypper addrepo --check --gpgcheck --refresh https://pkg.jenkins.io/opensuse Jenkins
zypper --gpg-auto-import-keys refresh
zypper --non-interactive install java-openjdk-headless
zypper --non-interactive install --from Jenkins jenkins

usermod --groups docker jenkins

systemctl enable jenkins-proxy.socket
