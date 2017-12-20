#!/bin/bash

#
# Installs a system with linux 
# If you are not thenoseman this is probably not for you!
#
#  wget -O - https://raw.githubusercontent.com/thenoseman/zsh_config/master/ubuntu-install/install.sh | bash
#

tee /dev/null <<EOF
======================================================================
= Ubuntu install script.                                             =
= If you are not thenoseman this is probably not for you             =
=                                                                    =
= If apt full-upgrade runs you might need to run the wget again      =
= since sometimes it exits the script ¯\_(ツ)_/¯                     =
=                                                                    =
= You will be asked for your password so ansible can run as root     =
=                                                                    =
======================================================================
EOF

# Update the system
sudo apt update
sudo apt full-upgrade || true

# install ansible
sudo apt-add-repository -u -y ppa:ansible/ansible
sudo apt-get install -y --no-install-recommends ansible
echo "localhost ansible_connection=local" | sudo tee /etc/ansible/hosts > /dev/null

# Run ansible locally
FOLDER=$(mktemp -d)
cd "${FOLDER}"
rm -f install.yml
wget -O install.yml "https://raw.githubusercontent.com/thenoseman/zsh_config/master/ubuntu-install/install.yml?cachebreaker=${RANDOM}"
ansible-playbook -K install.yml
