$script = <<-SCRIPT
# run the rancher server container
sudo docker run --name=rancher -d --restart=unless-stopped -p 8080:80 -p 8443:443 -v /var/lib/rancher:/var/lib/rancher rancher/rancher:v2.0.6
echo Server starting...
while ! curl -sk https://localhost:8443/ping; do sleep 5; done

# API calls based on examples from https://gist.github.com/superseb

# login to API
LOGINRESPONSE=`curl -s 'https://localhost:8443/v3-public/localProviders/local?action=login' -H 'content-type: application/json' --data-binary '{"username":"admin","password":"admin"}' --insecure`
LOGINTOKEN=`echo $LOGINRESPONSE | jq -r .token`
APIRESPONSE=`curl -s 'https://localhost:8443/v3/token' -H 'content-type: application/json' -H "Authorization: Bearer $LOGINTOKEN" --data-binary '{"type":"token","description":"automation"}' --insecure`
APITOKEN=`echo $APIRESPONSE | jq -r .token`

# set server url to mach the host name
RANCHER_SERVER=https://rancher2:8443
curl -s 'https://localhost:8443/v3/settings/server-url' -H 'content-type: application/json' -H "Authorization: Bearer $APITOKEN" -X PUT --data-binary '{"name":"server-url","value":"'$RANCHER_SERVER'"}' --insecure > /dev/null

# create cluster "local-cluster"
CLUSTERRESPONSE=`curl -s 'https://localhost:8443/v3/cluster' -H 'content-type: application/json' -H "Authorization: Bearer $APITOKEN" --data-binary '{"type":"cluster","nodes":[],"rancherKubernetesEngineConfig":{"ignoreDockerVersion":true},"name":"local-cluster"}' --insecure`
CLUSTERID=`echo $CLUSTERRESPONSE | jq -r .id`

# create token
curl -s 'https://localhost:8443/v3/clusterregistrationtoken' -H 'content-type: application/json' -H "Authorization: Bearer $APITOKEN" --data-binary '{"type":"clusterRegistrationToken","clusterId":"'$CLUSTERID'"}' --insecure > /dev/null

# run the cluster agent
AGENTCMD=`curl -s 'https://localhost:8443/v3/clusterregistrationtoken?id="'$CLUSTERID'"' -H 'content-type: application/json' -H "Authorization: Bearer $APITOKEN" --insecure | jq -r '.data[].nodeCommand' | head -1`
echo `$AGENTCMD --etcd --controlplane --worker`

# generate kubeconfig for kubectl
mkdir .kube
curl -s -u $APITOKEN https://localhost:8443/v3/clusters/$CLUSTERID?action=generateKubeconfig -X POST -H 'content-type: application/json' --insecure | jq -r .config > .kube/config

# run portainer on port 9000
# useful to see what's happening at docker container level
sudo docker volume create portainer_data
sudo docker run -d -p 9000:9000 --name portainer --restart always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer:1.19.1
SCRIPT

Vagrant.configure("2") do |config|
  config.vm.provider "virtualbox" do |vb|
    vb.name = "rancher2"
    vb.cpus = 4
    vb.memory = 6144
  end

  config.vm.box = "sgdan/rancher2"
  config.vm.synced_folder ".", "/vagrant", disabled: true
  config.vm.network "private_network", ip: "192.168.88.100"
  config.vm.provision "shell", inline: $script
end
