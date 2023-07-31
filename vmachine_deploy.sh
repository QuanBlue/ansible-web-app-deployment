#!/bin/bash

# Source the environment file to load the variables
source ./env_vars.sh

remote_vm_names=${!REMOTE_MACHINE_PORT_MAPPING[@]}

# change dir
info header "Change working directory"
info "Changing..."
cd ./vagrant/
info "Complete!"

info header "Remove vms"
info "Removing..."
vagrant destroy --force "ansible_controller"
for vm_name in ${remote_vm_names[@]}; do
   vagrant destroy --force ${vm_name}
done
info "Complete!"

# remove old files
info header "Remove old files"
info "Removing..."
rm -rf ./.vagrant
rm -rf ./ssh
info "Complete!"

# create ssh key
info header "Generate ssh key"
info "Generating..."
mkdir ssh
ssh-keygen -t rsa -f ./ssh/id_rsa -N ''
info "Complete!"

# start vagrant
info header "Start vagrant"
info "Starting..."
vagrant up
info "Complete!"

generate inventories file
info header "Generate inventories file"
info "Generating..."
bash ./bootstrap/inventories_generator.sh
info "Complete!"

info header "Connect to remote machine"
info "Connecting..."
for vm_name in ${remote_vm_names[@]}; do
   vm_ipv4=$(VBoxManage guestproperty get ${vm_name} /VirtualBox/GuestInfo/Net/1/V4/IP | awk '{print $2}')
   command="printf "exit\n" | vagrant ssh ansible_controller -c 'ssh -o StrictHostKeyChecking=no vagrant@${vm_ipv4}'"
   eval $command
done
info "Complete!"

# copy inventories file to ansible controller
info header "Copy inventories file to ansible controller"
info "Copying..."
vagrant scp ../ansible/ ansible_controller:/home/vagrant/
info "Complete!"

# run playbook
info header "Run playbook"
info "Running..."
vagrant ssh ansible_controller -c 'cd ansible && ansible-playbook -i inventories/hosts.ini playbooks/playbook.yml'
info "Complete!"
