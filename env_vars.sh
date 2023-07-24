declare -A REMOTE_MACHINE_PORT_MAPPING=(
   [frontend]=3000
   [backend]=5000
   [grafana]=4000
   [prometheus]=9090
   [alertmanager]=9093
)

export REMOTE_MACHINE_PORT_MAPPING
