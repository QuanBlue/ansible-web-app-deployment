#!/bin/bash

# Source the environment file to load the variables
source ./env_vars.sh

NODE_EXPORTER_MACHINES=(
   backend
   frontend
)

NETWORK=${NETWORK:-ansible-net}
INVENTORY="./ansible/inventories/hosts.ini"
CONTROLLER_PATH_TO_INVNETORY="/etc/ansible/inventories/hosts.ini"
CONTROLLER_PATH_TO_PLAYBOOK="/etc/ansible/playbooks/playbook.yml"

# Function to print messages in pretty format
info() {
   if [ "$1" = "header" ]; then
      tput bold       # Sets the text to bold
      tput setaf 7    # Sets the text color to white (ANSI color code 7)
      tput setab 2    # Sets the background color to green (ANSI color code 2)
      printf "\n$2\n" # Prints the message passed as an argument to the function
      tput sgr0       # Resets text attributes (color, boldness, etc.) to default
      tput el
   else
      tput bold    # Sets the text to bold
      tput setaf 2 # Sets the text color to green (ANSI color code 2)
      printf "$1"  # Prints the message passed as an argument to the function without new line
      tput sgr0    # Resets text attributes (color, boldness, etc.) to default
      tput el
   fi
}

# Function to split string
split_string() {
   local input_string="$1"    # Input string
   local delimiter="$2"       # Delimiter character or string
   local -n output_array="$3" # Output array variable (passed by reference)

   IFS="$delimiter" read -r -a output_array <<<"$input_string"
}

# Remove old containers
info header "Remove old containers"
info "Removing..."
echo
docker rm -f ansible-controller
for machine in ${!REMOTE_MACHINE_PORT_MAPPING[@]}; do
   docker rm -f $machine
done
info "Complete!"

# Create network
info header "Create network '${NETWORK}'"
info "Creating..."
docker network create --driver=bridge ${NETWORK}
info "Complete!"

# Create Ansible container
info header "Create Ansible controller container"
info "Creating..."
docker build -t ansible-controller:v1 -f ./dockerfile/Dockerfile-ansible-machine .
docker run -itd \
   --name ansible-controller \
   --network ${NETWORK} \
   --volume ./ansible/:/etc/ansible/ \
   ansible-controller:v1
rsa_pub=$(docker exec -it ansible-controller sh -c 'cat ~/.ssh/id_rsa.pub')
info "Complete!"

# Build REMOTE MACHINE container
info header "Create Remote Machine container"
info "Building image..."
docker build -t ubuntu-node:20.04 -f ./dockerfile/Dockerfile-remote-machine .
info "Complete!"

# Create REMOTE MACHINE container
for machine in ${!REMOTE_MACHINE_PORT_MAPPING[@]}; do
   info "Creating ${machine} VPS... "

   docker run -itd \
      --name=${machine} \
      --publish=${REMOTE_MACHINE_PORT_MAPPING[$machine]}:${REMOTE_MACHINE_PORT_MAPPING[$machine]} \
      --network=${NETWORK} \
      --hostname=${machine} \
      ubuntu-node:20.04

   docker exec -it ${machine} sh -c "mkdir -p /root/.ssh && echo '${rsa_pub}' > /root/.ssh/authorized_keys -vvv"

   info "Complete!"

done
info "Complete!"

# Get IP address of containers
info header "Get IP address of containers"
info "Getting..."
delimiter=";"
ipv4=$(docker network inspect --format="{{range .Containers}}{{.Name}}:{{.IPv4Address}}{{\"$delimiter\"}}{{end}}" $NETWORK)
split_string "$ipv4" "$delimiter" ipv4_array
info "Complete!"

# Generate inventory content
info header "Generate inventory content"
info "Generating..."
inventory=""
node_exporter_inventory="[node_exporter]"
for element in "${ipv4_array[@]}"; do
   split_string "$element" ":" machine_props
   split_string "${machine_props[1]}" "/" ip

   machine_name=${machine_props[0]}
   machine_ip=${ip[0]}

   inventory+="[${machine_name}]"
   inventory+="\n${machine_name}_host ansible_host=${machine_ip}\n\n"

   echo "machine_name: ${machine_name}"
   echo "machine_ip: ${machine_ip}"
   if [ "${machine_name}" == "backend" ] || [ "${machine_name}" == "frontend" ]; then
      echo "true"
      node_exporter_inventory+="\n${machine_name}_host ansible_host=${machine_ip}"
   fi

   if [ ${machine_name} != "ansible" ]; then
      # check connection from Controller to Nodes
      info "Checking connection from Controller to ${machine_name}..."
      printf "exit\n" | docker exec -i ansible-controller sh -c "ssh -o 'StrictHostKeyChecking=no' root@${machine_ip}"
      info "Complete!"
   fi
done
inventory+=$node_exporter_inventory
info "Complete!"

# Write inventory file
info header "Write inventory file"
info "Writing..."
echo -e $inventory >$INVENTORY
info "Complete!"

# Check Inventory file
info header "List all hosts Inventory file"
info "Listing..."
docker exec -it ansible-controller sh -c "ansible-inventory -i $CONTROLLER_PATH_TO_INVNETORY --list"
info "Complete!"

# Test ping to Grafana host
info header "Test ping to Grafana host"
info "Checking..."
docker exec -it ansible-controller sh -c "ansible -i $CONTROLLER_PATH_TO_INVNETORY -m ping grafana"
info "Complete!"

# Check connection from Controller to node (client)
info header "Play playbook"
info "Playing..."
docker exec -it ansible-controller sh -c "ansible-playbook -i $CONTROLLER_PATH_TO_INVNETORY $CONTROLLER_PATH_TO_PLAYBOOK"
info "Complete!"
