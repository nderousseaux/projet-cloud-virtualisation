job "web" {
  datacenters = ["homme-de-fer"]

  group "web" {
    count = 2

    network {
      
      port "web" {
        to = 3000
        host_network = "internal"
      }
    }

    task "web" {
      driver = "docker"
      config {
        force_pull = true
        image = "quay.io/cloud-projet/web:$version"
        ports = ["web"]
      }

      env {
        PORT    = "${NOMAD_PORT_web}"
        NODE_IP = "${NOMAD_IP_web}"
      }

			service {
				name = "web"
				port = "web"

				check {
					name     = "alive"
					type     = "http"
					protocol = "http"
					path     = "/"
					interval = "10s"
					timeout  = "2s"
				}
			}

      resources {
        cpu    = 200
        memory = 256
      }
    }

    scaling {
      enabled = true
      min = 2
      max = 10
    }
	}
}