# -*- mode: ruby -*-
# vi: set ft=ruby :

$IPs = {
  "m1" => "10.0.40.41",
  "w1" => "10.0.40.51"
}
Vagrant.configure("2") do |config|
  config.vm.box = "debian/contrib-jessie64"
  config.vm.box_check_update = false
  if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.scope = "box"
    config.cache.synced_folder_opts = {
      type: "nfs",
      mount_options: ['rw', 'vers=3', 'tcp', 'nolock']
    }
  end
  $IPs.map do |k,v|
    config.vm.define "#{k}" do |m|
      m.vm.hostname = "#{k}"
      m.vm.network "private_network", ip: "#{v}"
      m.vm.provision "shell", path: "docker11-provision.sh"
    end
  end
end
