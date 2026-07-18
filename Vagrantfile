
Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/jammy64"

  # Forward the React/Nginx frontend port
  config.vm.network "forwarded_port",
                    guest: 3000,
                    host: 3001,
                    host_ip: "127.0.0.1"

  # Forward the backend API port
  config.vm.network "forwarded_port",
                    guest: 5000,
                    host: 5001,
                    host_ip: "127.0.0.1"

  # VirtualBox configuration
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "2048"
    vb.cpus = 2
    vb.name = "dockercat-stage1"
  end

  # Run the Ansible playbook after the VM is created
  config.vm.provision "ansible" do |ansible|
    ansible.playbook = "playbook.yml"
  end
end