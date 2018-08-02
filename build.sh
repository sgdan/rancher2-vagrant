# download and unpack the base box
mkdir -p .cache
wget -c https://vagrantcloud.com/bento/boxes/ubuntu-18.04/versions/201807.12.0/providers/virtualbox.box -O .cache/ubuntu-18.04-base.box
tar zxvf .cache/ubuntu-18.04-base.box -C .cache

# do the build (add the docker images for rancher)
packer build -force pack.json
vagrant box add --force rancher2 rancher2.box
