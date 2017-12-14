#!/bin/bash

#
# Installs a system with linux 
# If you are not thenoseman this is probably not for you!
#
# curl -sSf https://raw.githubusercontent.com/thenoseman/zsh_config/master/ubuntu-install/install.sh | bash
# or
# curl -LsSf https://goo.gl/J2Xudx | bash
#

# Update the system
sudo apt update
sudo apt full-upgrade

# install ansible
sudo apt-add-repository -u -y ppa:ansible/ansible
sudo apt-get install -y --no-install-recommends ansible
echo "localhost ansible_connection=local" | sudo tee /etc/ansible/hosts > /dev/null

# Run ansible locally
FOLDER=$(mktemp -d)
cd "${FOLDER}"
curl -LO "https://raw.githubusercontent.com/thenoseman/zsh_config/master/ubuntu-install/install.yml"
ansible-playbook -K install.yml
