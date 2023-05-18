job "haproxy" {
  datacenters = ["homme-de-fer"]
  type        = "service"

  # On prefère utiliser un noeud plutot qu'un autre
  affinity {
    attribute = "${node.unique.id}"
    value     = "ae367b9f-487e-2a9f-340e-9396284ee72b"
  }


  group "haproxy" {
    count = 1

    # Il sera disponible depuis 8081
    network {
      port "http" {
        static = 8081
      }
    }

    service {
      name = "haproxy"

      check {
        name     = "alive"
        type     = "tcp"
        port     = "http"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "haproxy" {
      driver = "docker"

      config {
        image        = "haproxy:2.0"
        network_mode = "host"

        volumes = [
          "local/haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg",
        ]
      }

      template {
        data = <<EOF
defaults
   mode http

frontend stats
  bind *:8081
   stats uri /stats
   stats show-legends
   no log

frontend http_front
   bind *:8081
   default_backend http_back

backend http_back
    balance roundrobin
    server-template cloud 1-10 _web._tcp.service.consul resolvers consul resolve-opts allow-dup-ip resolve-prefer ipv4 check

resolvers consul
    nameserver consul 172.16.1.18:53
    accepted_payload_size 8192
    hold valid 5s
EOF

        destination = "local/haproxy.cfg"
      }

      resources {
        cpu    = 200
        memory = 128
      }
    }
  }
}
