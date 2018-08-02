Vagrant.configure("2") do |config|
  config.vm.provider "virtualbox" do |vb|
    vb.name = "rancher2"
    vb.cpus = 2
    vb.memory = 6144
  end

  config.vm.box = "sgdan/rancher2"
  config.vm.synced_folder ".", "/vagrant", disabled: true
  config.vm.network "private_network", ip: "192.168.88.100"
  config.vm.hostname = "rancher2"
  config.vm.provision "shell", path: "provision.sh"
end
