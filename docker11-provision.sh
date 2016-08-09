#!/usr/bin/env bash
sudo apt-get purge "lxc-docker*"
sudo apt-get purge "docker.io*"
sudo apt-get update
sudo apt-get -y install apt-transport-https ca-certificates
sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
echo "deb https://apt.dockerproject.org/repo debian-jessie main" | sudo tee /etc/apt/sources.list.d/docker.list 
sudo apt-get update
sudo apt-get -y install docker-engine=1.11.2-0~jessie
sudo groupadd docker
sudo gpasswd -a vagrant docker
sudo service docker start
if grep -Fxqv "cgroup_enable=memory swapaccount=1" /etc/default/grub
then
    sudo sed -i.bak 's/GRUB_CMDLINE_LINUX="/GRUB_CMDLINE_LINUX="cgroup_enable=memory swapaccount=1 /' /etc/default/grub
fi
sudo update-grub2
