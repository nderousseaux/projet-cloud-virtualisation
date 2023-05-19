job "haproxy" {
  datacenters = ["homme-de-fer"]
  type        = "service"

  group "haproxy" {
    count = 1

    # Il sera disponible depuis 8081
    network {
      port "http" {
        static = 8081
        host_network = "public"
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
   maxconn 10000

frontend stats
  bind *:8081
   stats uri /stats
   stats show-legends
   no log

backend front_back
  http-response set-header Access-Control-Allow-Origin "*"
  balance roundrobin
  server-template web 1-10 _web._tcp.service.consul resolvers consul resolve-opts allow-dup-ip resolve-prefer ipv4 check

backend api_back
  http-response set-header Access-Control-Allow-Origin "*"
  balance roundrobin  
  server-template api 1-10 _api._tcp.service.consul resolvers consul resolve-opts allow-dup-ip resolve-prefer ipv4 check

backend poubelle
  mode http
  http-request deny

frontend http-in
  bind *:8081
  mode http
  acl is_api hdr(Host) -i api.homme-de-fer.100do.se
  acl is_api hdr(Host) -i api.homme-de-fer.100do.se:8081
  acl is_web hdr(Host) -i homme-de-fer.100do.se
  acl is_web hdr(Host) -i homme-de-fer.100do.se:8081
  use_backend api_back if is_api
  use_backend front_back if is_web
  default_backend poubelle


resolvers consul
    nameserver consul 172.16.1.18:53
    accepted_payload_size 8192
    hold valid 5s
EOF

        destination = "local/haproxy.cfg"
      }

      resources {
        cpu    = 200
        memory = 256
      }
    }
  }
}
