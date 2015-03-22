# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "puppetlabs/ubuntu-14.04-64-puppet"

  config.vm.network :public_network

  config.vm.synced_folder ".", "/vagrant", type: "rsync", rsync__exclude: [".git/", "_build/"]

  config.vm.define "ohaibot", primary: true do |node|
    node.vm.provision "puppet" do |puppet|
      puppet.manifests_path = "manifests"
      puppet.manifest_file  = "ohaibot.pp"
      puppet.module_path = ["modules"]
    end
  end

  config.vm.define "ircd", autostart: false do |node|
    node.vm.provision "puppet" do |puppet|
      puppet.manifests_path = "manifests"
      puppet.manifest_file  = "ircd.pp"
      puppet.module_path = ["modules"]
    end
  end

end
