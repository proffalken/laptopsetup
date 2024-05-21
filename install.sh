#!/bin/bash
#
# install.sh - Configure a laptop to a base standard
#
# Copyright 2024 Matthew Macdonald-Wallace
#
set -eu -o pipefail

if ! command -v sshd &> /dev/null
then
	echo -e "=== Installing OpenSSH Server"
	sudo apt install -y openssh-server
else
	echo -e "=== SSH Server already installed, skipping"
fi
if ! command -v ansible &> /dev/null
then
	echo -e "=== Installing Ansible"
	sudo apt install -y ansible
else
	echo -e "=== Ansible already installed, skipping"
fi
if ! command -v jq &> /dev/null
then
	echo -e "=== Installing JQ"
	sudo apt install -y jq
else
	echo -e "=== JQ already installed, skipping"
fi

echo -e "=== Setting up SSH Keys"
if [ ! -f $HOME/.ssh/*.pub ]
then
	ssh-keygen
fi
ssh-copy-id ${USER}@localhost

echo -e "=== Starting setup, acting against the following hosts:"
ansible-inventory -i inventory.ini --list | jq ".localhost.hosts"

echo -e "=== Setup begins..."
ansible-playbook -i inventory.ini playbook.yaml
echo -e "=== Setup ends"
