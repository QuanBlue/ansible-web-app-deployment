# Load ec2 environment variables
source ./aws-ec2/.env
source ./aws-ec2/env_vars.sh

declare -A REMOTE_MACHINE_PORT_MAPPING=(
   [frontend]=3000
   [backend]=5000
   [grafana]=4000
   [prometheus]=9090
   [alertmanager]=9093
)

export INVENTORY="./ansible/inventories/hosts.ini"
export CONTROLLER_PATH_TO_INVNETORY="/etc/ansible/inventories/hosts.ini"
export CONTROLLER_PATH_TO_PLAYBOOK="/etc/ansible/playbooks/playbook.yml"

export REMOTE_MACHINE_PORT_MAPPING

# Function to print messages in pretty format
# input message $1
function info() {
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

# Convert the dictionary to an array
# input dictionary $1 -> output key array
function dict_to_array() {
   declare -n dict="$1"
   local arr=()

   for key in "${!dict[@]}"; do
      arr+=("$key")
   done

   echo "${arr[@]}"
}
