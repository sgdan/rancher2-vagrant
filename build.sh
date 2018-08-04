# build the box file and add for local testing
packer build -force pack.json
vagrant box add --force rancher2 rancher2.box
