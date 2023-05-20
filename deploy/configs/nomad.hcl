#/etc/nomad.d/nomad.hcl

datacenter = "homme-de-fer"
data_dir = "/opt/nomad"
name = <node_name>

bind_addr = "0.0.0.0"

advertise {
  http = "{{ GetInterfaceIP `vxlan100` }}"
  rpc = "{{ GetInterfaceIP `vxlan100` }}"
  serf = "{{ GetInterfaceIP `vxlan100` }}"
}

# Ce n'est pas un cluster
server {
  enabled = false
}

# C'est un client
client {
  enabled = true
	network_interface = "vxlan100"
  host_network "internal" {
    cidr = "<ip_fixe_node>/<prefix>" # IP fixe du noeud
    interface = "vxlan100"
  }

  host_network "public" {
    cidr = "<ip_flottante_node>/<prefix>" # Ip flottante
    interface = "vxlan100"
  }
}

# Consul
consul {
  address = "127.0.0.1:8500"
}

# Authentification docker
plugin "docker" {
  config {
    auth {
      config = "/home/ubuntu/.docker/config.json"
    }
  }
}