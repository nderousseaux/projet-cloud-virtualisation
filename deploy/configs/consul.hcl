#/etc/consul.d/consul.hck

datacenter = "homme-de-fer"
data_dir = "/opt/consul"
node_name = <node_name>

client_addr = "0.0.0.0"

advertise_addr = "{{ GetInterfaceIP `vxlan100` }}"

ui_config {
  enabled = true
}

server = true

# Addresse du noeud leader
retry_join = ["homme-de-fer.internal.100do.se"]

addresses {
  dns = "{{ GetInterfaceIP `vxlan100` }}"
}

ports {
  dns = 53
}

# List of upstream DNS servers to forward queries to
recursors = ["1.1.1.1", "1.0.0.1"]
