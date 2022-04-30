# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

	if Vagrant.has_plugin? "vagrant-vbguest"
		config.vbguest.no_install = true
		config.vbguest.auto_update = false
		config.vbguest.no_remote = true
	end
	 
	config.vm.define :principal do |principal|
		principal.vm.box = "bento/ubuntu-20.04"
		principal.vm.network :private_network, ip: "192.168.100.2"
		principal.vm.provision "shell", path: "principal.sh"
		principal.vm.hostname = "principal"
		principal.vm.synced_folder "public/", "/home/vagrant"
	end
	 
	config.vm.define :web1 do |web1|
		web1.vm.box = "bento/ubuntu-20.04"
		web1.vm.network :private_network, ip: "192.168.100.3"
		web1.vm.provision "shell", path: "web1.sh"
		web1.vm.hostname = "web1"
		web1.vm.synced_folder "public/", "/home/vagrant"
	end
	
	config.vm.define :web2 do |web2|
		web2.vm.box = "bento/ubuntu-20.04"
		web2.vm.network :private_network, ip: "192.168.100.4"
		web2.vm.provision "shell", path: "web2.sh"
		web2.vm.hostname = "web2"
		web2.vm.synced_folder "public/", "/home/vagrant"
	end
	
	config.vm.define :web3 do |web3|
		web3.vm.box = "bento/ubuntu-20.04"
		web3.vm.network :private_network, ip: "192.168.100.5"
		web3.vm.provision "shell", path: "web3.sh"
		web3.vm.hostname = "web3"
		web3.vm.synced_folder "public/", "/home/vagrant"
	end

	#config.vm.define :web4 do |web4|
		#web4.vm.box = "bento/ubuntu-20.04"
		#web4.vm.network :private_network, ip: "192.168.100.6"
		#web4.vm.provision "shell", path: "web4.sh"
		#web4.vm.hostname = "web4"
		#web4.vm.synced_folder "public/", "/home/vagrant"
	#end

	config.trigger.after :up do |trigger|
		trigger.run = {path: "haproxy.sh"}
	end
end