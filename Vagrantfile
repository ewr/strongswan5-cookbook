# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.hostname  = "vpn.vm"
  config.vm.box       = "canonical-ubuntu-12.04"
  config.vm.box_url   = "http://cloud-images.ubuntu.com/vagrant/precise/current/precise-server-cloudimg-amd64-vagrant-disk1.box"
  
  config.vm.network :private_network, ip: "192.168.133.22"
  
  config.omnibus.chef_version = :latest
  
  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm",:id,"--cpus",2]
    vb.customize ["modifyvm",:id,"--memory",2*1024]
  end

  config.berkshelf.enabled = true
  
  config.vm.provision :chef_solo do |chef|
    chef.json = {
      strongswan: {
        subnets:    "10.0.2.0/24",
        left:       "192.168.133.22",
        ip_range:   "10.0.4.20/25"
      }
    }

    chef.run_list = [
      "recipe[strongswan5]",
      "recipe[strongswan5::test_user]"
    ]
  end
end