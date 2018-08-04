#!/bin/ash
set -eux

echo http://mirror.aarnet.edu.au/pub/alpine/v3.8/community/ >> /etc/apk/repositories
apk update && apk upgrade
apk add sudo ca-certificates openssl curl bash jq docker

# start docker and make sure it starts up at boot
service docker start
rc-update add docker boot

# add the vagrant user and let it use root permissions without sudo asking for a password.
adduser -D vagrant
echo 'vagrant:vagrant' | chpasswd
adduser vagrant wheel
echo '%wheel ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/wheel

# install the vagrant public key.
# NB vagrant will replace it on the first run.
install -d -m 700 /home/vagrant/.ssh
wget -qO /home/vagrant/.ssh/authorized_keys https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub
chmod 600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant:vagrant /home/vagrant/.ssh

# install the VirtualBox Guest Additions.
apk add virtualbox-guest-additions virtualbox-guest-modules-virt
rc-update add virtualbox-guest-additions
echo vboxsf >>/etc/modules
modinfo vboxguest

# get the Rancher 2.0 server image
docker image pull rancher/rancher:v2.0.6

sed -i '/^PermitRootLogin yes/d' /etc/ssh/sshd_config
echo "UseDNS no" >> /etc/ssh/sshd_config

# zero the free disk space -- for better compression of the box file.
dd if=/dev/zero of=/EMPTY bs=1M || true && sync && rm -f /EMPTY && sync
