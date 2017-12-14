#!/bin/bash

#
# Installs a system with linux 
# If you are not thenoseman this is probably not for you!
#

# Update the system
sudo apt update
sudo apt full-upgrade

# install ansible
sudo apt-add-repository -u -y ppa:ansible/ansible
sudo apt-get install -y --no-install-recommends ansible
echo "localhost ansible_connection=local" | sudo tee /etc/ansible/hosts > /dev/null

# Run ansible locally
ansible-playbook all -K
