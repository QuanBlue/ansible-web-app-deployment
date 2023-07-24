# Source the environment file to load the variables
source ../env_vars.sh

inventory=""
node_exporter_inventory="[node_exporter]"

for vm_name in ${!REMOTE_MACHINE_PORT_MAPPING[@]}; do
   vm_ipv4=$(VBoxManage guestproperty get ${vm_name} /VirtualBox/GuestInfo/Net/1/V4/IP | awk '{print $2}')

   if [ "${vm_name}" == "backend" ] || [ "${vm_name}" == "frontend" ]; then
      node_exporter_inventory+="\n${vm_name}_host ansible_host=${vm_ipv4}"
   fi

   inventory+="[${vm_name}]\n"
   inventory+="${vm_name}_host ansible_host=${vm_ipv4}\n\n"
done

inventory+=$node_exporter_inventory
echo -e $inventory >../ansible/inventories/hosts.ini
