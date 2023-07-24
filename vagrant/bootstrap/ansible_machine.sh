apt-get update
export DEBIAN_FRONTEND=noninteractive

sudo apt-get install net-tools

# install ansible
sudo apt-add-repository ppa:ansible/ansible
sudo apt-get update
sudo apt-get install ansible -y
