# install docker
# install jq tool for parsing JSON responses (used later when starting rancher agent)
sudo apt-get update && sudo apt-get install -y docker.io jq

# install kubectl to use on the VM
sudo snap install kubectl --classic

# pull images for Rancher 2.0 server and node
sudo docker image pull rancher/rancher:v2.0.6
sudo docker image pull rancher/rancher-agent:v2.0.6
sudo docker image pull rancher/hyperkube:v1.10.5-rancher1
sudo docker image pull rancher/coreos-etcd:v3.1.12
sudo docker image pull rancher/pause-amd64:3.1
sudo docker image pull rancher/rke-tools:v0.1.10
sudo docker image pull rancher/nginx-ingress-controller:0.10.2-rancher3
sudo docker image pull rancher/calico-node:v3.1.1
sudo docker image pull rancher/calico-cni:v3.1.1
sudo docker image pull rancher/k8s-dns-dnsmasq-nanny-amd64:1.14.8
sudo docker image pull rancher/k8s-dns-sidecar-amd64:1.14.8
sudo docker image pull rancher/k8s-dns-kube-dns-amd64:1.14.8
sudo docker image pull rancher/coreos-flannel:v0.9.1
sudo docker image pull rancher/nginx-ingress-controller-defaultbackend:1.4
sudo docker image pull rancher/cluster-proportional-autoscaler-amd64:1.0.0

# useful to see what's happening at the docker container level
sudo docker image pull portainer/portainer:1.19.1

# clean up so the resulting box is smaller

# from https://github.com/chef/bento/blob/master/ubuntu/scripts/cleanup.sh
sudo apt-get -y autoremove;
sudo apt-get -y clean;
sudo rm -rf /usr/share/doc/*
sudo find /var/cache -type f -exec rm -rf {} \;
sudo find /var/log/ -name *.log -exec rm -f {} \;
sudo truncate -s 0 /etc/machine-id

# remainder is from https://github.com/chef/bento/blob/master/_common/minimize.sh

# Whiteout root
count=$(df --sync -kP / | tail -n1  | awk -F ' ' '{print $4}')
count=$(($count-1))
sudo dd if=/dev/zero of=/tmp/whitespace bs=1M count=$count || echo "dd exit code $? is suppressed";
sudo rm /tmp/whitespace

# Whiteout /boot
count=$(df --sync -kP /boot | tail -n1 | awk -F ' ' '{print $4}')
count=$(($count-1))
sudo dd if=/dev/zero of=/boot/whitespace bs=1M count=$count || echo "dd exit code $? is suppressed";
sudo rm /boot/whitespace

set +e
swapuuid="`/sbin/blkid -o value -l -s UUID -t TYPE=swap`";
case "$?" in
    2|0) ;;
    *) exit 1 ;;
esac
set -e

if [ "x${swapuuid}" != "x" ]; then
    # Whiteout the swap partition to reduce box size
    # Swap is disabled till reboot
    swappart="`readlink -f /dev/disk/by-uuid/$swapuuid`";
    sudo /sbin/swapoff "$swappart";
    sudo dd if=/dev/zero of="$swappart" bs=1M || echo "dd exit code $? is suppressed";
    sudo /sbin/mkswap -U "$swapuuid" "$swappart";
fi

sync;
