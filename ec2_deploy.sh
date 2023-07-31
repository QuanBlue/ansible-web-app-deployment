#!/bin/bash

# Source the environment file to load the variables
source ./env_vars.sh

SETTING_PATH="./aws-ec2/setting/"
KEY_PAIR_NAME_PATH="${SETTING_PATH}${KEY_PAIR_NAME}.pem"
INSTANCE_NAMES=($(dict_to_array REMOTE_MACHINE_PORT_MAPPING))

function get_machine_ids() {
   instance_name=$1

   instance_ids=$(
      aws ec2 describe-instances \
         --filters "Name=tag:Name,Values=${instance_name}" \
         --query "Reservations[].Instances[].InstanceId" \
         --output text \
         --no-cli-pager
   )

   echo ${instance_ids}
}

# input: id
# output: status
function get_machine_status() {
   instance_id=$1

   instance_status=$(
      aws ec2 describe-instances \
         --instance-ids "${instance_id}" \
         --query "Reservations[*].Instances[*].State.Name" \
         --output text \
         --no-cli-pager
   )

   echo ${instance_status}
}

# input: name
# output: id
function get_running_machine_ids() {
   instance_name=$1

   instance_ids=$(get_machine_ids ${instance_name})

   for instance_id in ${instance_ids}; do
      machine_status=$(get_machine_status ${instance_id})

      if [[ "$machine_status" == "running" ]]; then
         echo ${instance_id}
         return
      fi
   done
}

function get_running_machine_ip() {
   instance_name=$1

   instance_id=$(get_running_machine_ids ${instance_name})

   instance_public_ip=$(
      aws ec2 describe-instances \
         --instance-ids "${instance_id}" \
         --query "Reservations[].Instances[].PublicIpAddress" \
         --output text \
         --no-cli-pager
   )

   echo ${instance_public_ip}
}

# ---------------------------------------------
function prequisites() {
   info header "Prequisites"

   info "Granting write permission to the script itself..."
   chmod a+w "$0"
   info "Complete!\n"

   info "Store previous aws configuaration..."
   if [ -d "~/.aws/" ]; then
      if [ -f "~/.aws/config" ]; then
         mv ~/.aws/config ~/.aws/config.bak
      fi
      if [ -f "~/.aws/credentials" ]; then
         mv ~/.aws/credentials ~/.aws/credentials.bak
      fi
   else
      mkdir -p ~/.aws
   fi
   info "Complete!\n"

   info "Removing key pair..."
   aws ec2 delete-key-pair \
      --key-name ${KEY_PAIR_NAME} \
      --no-cli-pager
   info "Complete!\n"

   info "Resetting setting folder..."
   if [ -d "${SETTING_PATH}" ]; then
      # If the folder exists, remove its contents (all files and subdirectories)
      rm -rf ${SETTING_PATH}*

   else
      # If the folder doesn't exist, create it
      mkdir ${SETTING_PATH}
   fi
   info "Complete!\n"

   info "Creating list of instance names..."
   INSTANCE_NAMES+=("ansible_controller")
   info "Complete!\n"

   # info "Generating ssh key..."
   # mkdir -p ./aws-ec2/ssh
   # ssh-keygen -t rsa -f ./aws-ec2/ssh/id_rsa -N ''
   # info "Complete!"
}

# ---------------------------------------------
function aws_setup() {
   info header "AWS setup"

   # Generate AWS configuration file
   info "Generating configuration..."
   aws_config="[default]\n"
   for config_field in ${!AWS_CONFIG[@]}; do
      aws_config+="${config_field} = ${AWS_CONFIG[${config_field}]}\n"
   done
   echo -e "$aws_config" >~/.aws/config
   info "Complete!\n"

   # Generate AWS credentials file
   info "Generating credentials..."
   aws_credentials="[default]\n"
   for config_field in ${!AWS_CREDENTIALS[@]}; do
      aws_credentials+="${config_field} = ${AWS_CREDENTIALS[${config_field}]}\n"
   done
   echo -e "$aws_credentials" >~/.aws/credentials
   info "Complete!"
}

# ---------------------------------------------
function create_ec2_machine() {
   info header "Create EC2 machine"

   info "Generating key pair..."
   aws ec2 create-key-pair \
      --key-name ${KEY_PAIR_NAME} \
      --query "KeyMaterial" \
      --output text >${KEY_PAIR_NAME_PATH}
   chmod 0400 ${KEY_PAIR_NAME_PATH}
   info "Complete!\n"

   info "Creating security group..."
   aws ec2 create-security-group \
      --group-name ${SECURITY_GROUP_NAME} \
      --description "Security group for Quanblue" \
      --no-cli-pager
   info "Complete!\n"

   info "Adding rule for security group..."
   aws ec2 authorize-security-group-ingress \
      --group-name ${SECURITY_GROUP_NAME} \
      --protocol tcp \
      --port 0-65535 \
      --cidr 0.0.0.0/0 \
      --no-cli-pager
   info "Complete!\n"

   info "Creating EC2 instance...\n"
   for instance_name in ${INSTANCE_NAMES[@]}; do
      printf "Creating '${instance_name}' machine..."
      aws ec2 run-instances \
         --image-id ${AMI_ID} \
         --instance-type ${INSTANCE_TYPE} \
         --key-name ${KEY_PAIR_NAME} \
         --security-groups ${SECURITY_GROUP_NAME} \
         --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=${instance_name}}]" \
         --no-cli-pager
      printf "Complete!\n"
   done
   info "Complete!\n"
}

# ---------------------------------------------
function terminate_ec2_machine() {
   info header "Terminate EC2 instance"

   info "Terminating...\n"

   for instance_name in ${INSTANCE_NAMES[@]}; do
      info "Removing all instances with name: ${instance_name}...\n"
      printf "Getting instance id..."
      instance_ids=$(get_machine_ids ${instance_name})
      printf "Complete!\n"

      for instance_id in $instance_ids; do
         printf "Terminating instance: ${instance_id}"
         aws ec2 terminate-instances \
            --instance-ids ${instance_id} \
            --no-cli-pager
         printf "Complete!\n"
      done
      info "Complete!\n"
   done

   info "Complete!\n"
}

# ---------------------------------------------
function generate_inventories() {
   info header "Generate inventories"

   info "Waiting for machines up (1min)..."
   sleep 1m
   info "Complete!\n\n"

   info "Generating inventory file...\n"
   inventory=""
   node_exporter_inventory="[node_exporter]"
   for instance_name in ${INSTANCE_NAMES[@]}; do
      printf "Getting ip address of '${instance_name}' machine..."
      instance_public_ip=$(get_running_machine_ip ${instance_name})
      printf "Complete!\n"

      inventory+="[$instance_name]"
      inventory+="\n${instance_name}_host ansible_host=${instance_public_ip}\n\n"

      if [ "${instance_name}" == "backend" ] || [ "${instance_name}" == "frontend" ]; then
         node_exporter_inventory+="\n${instance_name}_host ansible_host=${instance_public_ip}"
      fi
   done
   info "Complete!\n"

   info "Writting inventory file..."
   inventory+="${node_exporter_inventory}"
   echo -e "$inventory" >${INVENTORY}
   info "Complete!\n"
}

# ---------------------------------------------
# Set up remote machine that, ansible machine can connect with them via ssh in root user
function setup_remote_machine() {
   info header "Setting up remote machine..."
   for instance_name in ${INSTANCE_NAMES[@]}; do
      if [ "${instance_name}" == "ansible_controller" ]; then
         continue
      fi

      info "${instance_name}:\n"
      printf "Getting ip address of '${instance_name}' machine..."
      instance_public_ip=$(get_running_machine_ip ${instance_name})
      printf "Complete!\n"

      connect_command="ssh -i ${KEY_PAIR_NAME_PATH} -o 'StrictHostKeyChecking=no' ubuntu@${instance_public_ip}"

      printf "Copying sshd_config to /home/ubuntu/sshd_config...\n"
      source="./aws-ec2/sshd_config"
      destination="/home/ubuntu/sshd_config"
      command="scp -o 'StrictHostKeyChecking=no' -i ${KEY_PAIR_NAME_PATH} ${source} ubuntu@${instance_public_ip}:${destination}"
      eval ${command}
      printf "Complete!\n"

      printf "Copying /home/ubuntu/sshd_config to /etc/ssh/sshd_config..."
      command="${connect_command} sudo cp /home/ubuntu/sshd_config /etc/ssh/sshd_config"
      eval ${command}
      printf "Complete!\n"

      printf "Copy /home/.ssh/authorized_keys to /root/.ssh/authorized_keys"
      authorized_keys=$(eval "${connect_command} 'cat ~/.ssh/authorized_keys'")
      command="${connect_command} 'echo ${authorized_keys} | sudo tee /root/.ssh/authorized_keys'"
      eval ${command}
      printf "Complete!\n"

      printf "Restarting ssh service..."
      command="${connect_command} sudo systemctl restart ssh"
      eval ${command}
      printf "Complete!\n"

      info "Complete!\n"
   done
   info "Complete!\n"
}

# ---------------------------------------------
function setup_ansible_machine() {
   ansible_machine_ip=$(get_running_machine_ip "ansible_controller")

   connect_command="ssh -i ${KEY_PAIR_NAME_PATH} -o 'StrictHostKeyChecking=no' ubuntu@${ansible_machine_ip}"
   copy_command="scp -i ${KEY_PAIR_NAME_PATH} -o 'StrictHostKeyChecking=no'"

   info header "Setting up ansible machine..."

   info "Waiting for 'ansible' machine up (1 min)..."
   sleep 1m
   info "Complete!\n\n"

   # copy init script to ansible machine
   info "Copying init script to ansible machine...\n"
   source="./vagrant/bootstrap/ansible_machine.sh"
   destination="/home/ubuntu"
   command="${copy_command} ${source} ubuntu@${ansible_machine_ip}:${destination}"
   eval ${command}
   info "Complete!\n\n"

   # run init script
   info "Running init script...\n"
   command="${connect_command} sudo bash /home/ubuntu/ansible_machine.sh"
   eval ${command}
   info "Complete!\n\n"

   info "Copying ansible config...\n"
   source="./ansible/"
   destination="/home/ubuntu"
   command="${copy_command} -r ${source} ubuntu@${ansible_machine_ip}:${destination}"
   eval ${command}

   printf "Copy from /home/ubuntu/ansible/ to /etc/ansible/..."
   command="${connect_command} 'sudo cp -rf ${destination}/ansible/* /etc/ansible/'"
   eval ${command}
   printf "Complete!\n"
   info "Complete!\n\n"

   info "Copying ssh key...\n"
   source=${KEY_PAIR_NAME_PATH}
   destination="/home/ubuntu"
   command="${copy_command} ${source} ubuntu@${ansible_machine_ip}:${destination}"
   eval ${command}
   info "Complete!\n\n"

   info "Adding remote machine to the list of known hosts...\n"
   for instance_name in ${INSTANCE_NAMES[@]}; do
      info "${instance_name}:\n"
      printf "Getting ip address of '${instance_name}' machine..."
      instance_public_ip=$(get_running_machine_ip ${instance_name})
      printf "Complete!\n"

      printf "Connecting ssh..."
      ansible_ssh_key="/home/ubuntu/${KEY_PAIR_NAME}.pem"
      command="${connect_command} ssh -i ${ansible_ssh_key} -o 'StrictHostKeyChecking=no' root@${instance_public_ip} exit"
      eval ${command}
      printf "Complete!\n"

      info "Complete!\n"
   done
   info "Complete!\n"
}

# # ---------------------------------------------
function run_ansible_playbook() {
   ansible_machine_ip=$(get_running_machine_ip "ansible_controller")

   info header "Running playbook..."

   info "Waiting (1 min) before run playbook..."
   sleep 1m
   info "Complete!\n\n"

   connect_command="ssh -i ${KEY_PAIR_NAME_PATH} -o 'StrictHostKeyChecking=no' ubuntu@${ansible_machine_ip}"
   control_command="ansible-playbook \
      --private-key ./${KEY_PAIR_NAME}.pem \
      -i /etc/ansible/inventories/hosts.ini /etc/ansible/playbooks/playbook.yml"
   command="${connect_command} '${control_command}'"
   eval ${command}
   info "Complete!\n"
}

# ---------------------------------------------
# main
prequisites
terminate_ec2_machine
aws_setup
create_ec2_machine
generate_inventories
setup_remote_machine
setup_ansible_machine
run_ansible_playbook
