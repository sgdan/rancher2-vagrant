# rancher2-vagrant

A vagrant box which runs a Rancher 2.0 server and single node Kubernetes cluster for local development.

- Based on the Chef base box [bento/ubuntu-18.04](https://github.com/chef/bento/tree/master/ubuntu)
- Runs a local VirtualBox VM with hostname `rancher2` and IP address `192.168.88.100`. For convenience it's assumed `192.168.88.100 rancher2` has been added to the `hosts` file.
- Installs and runs docker 17.12.1-ce
- Starts a [Rancher 2.0](https://hub.docker.com/r/rancher/rancher/) server container and sets the server url to https://rancher2:8443/ where you can access the Rancher UI.
- Starts a [Rancher Agent](https://hub.docker.com/r/rancher/rancher-agent) container that will create a local Kubernetes cluster and link it to the Rancher Server. The API is accessible on https://rancher2/.
- Also contains  [Portainer](https://portainer.io/) container because I like to be able to see which containers Kubernetes is running. Accessible at http://rancher2:9000/.

## Build

The size of the box is quite large (1.4G) because the build process pulls all the required docker images into the box image. This means it can start up quicker. If you have [Packer](https://www.packer.io/) and [VirtualBox](https://www.virtualbox.org/) installed you can run `build.sh` to create a new box image.

Startup of images is left to the vagrant provision script so that fresh server tokens are generated at that time and not included in the box image.

## Run

1. Add `192.168.88.100 rancher2` to local hosts file
2. Use the supplied vagrant file and run `vagrant up`
3. Go to Portainer and set the admin password: http://rancher2:9000/#/init/admin. Choose "Manage the local Docker environment" and connect.
4. Go to Rancher 2.0 and set the admin password: https://rancher2:8443/
5. Run `vagrant ssh` to log into the VM, then run `kubectl cluster-info`.

If you don't want to use the pre-built box you can:
- just point to `bento/ubuntu-18.04` from the Vagrantfile
- edit the `provision.sh` script to install docker, jq and kubectl:
  ```
  sudo apt-get update && sudo apt-get install -y docker.io jq
  sudo snap install kubectl --classic
  ```
- consider removing image versions to get the latest images
It will take longer to start up though as it downloads all the docker images.

## Useful references
- https://ketzacoatl.github.io/posts/2017-06-01-use-existing-vagrant-box-in-a-packer-build.html describes how to build using another vagrant box as base, this build starts from https://vagrantcloud.com/bento/boxes/ubuntu-18.04/versions/201807.12.0/providers/virtualbox.box
- see https://gist.github.com/superseb/29af10c2de2a5e75ef816292ef3ae426 for example of Rancher 2 REST API calls to create and add a new cluster
- see https://gist.github.com/superseb/cad9b87c844f166b9c9bf97f5dea1609 for example of Rancher 2 REST API calls to create kubeconfig
