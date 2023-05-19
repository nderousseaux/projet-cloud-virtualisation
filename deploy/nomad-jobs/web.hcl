job "web" {
  datacenters = ["homme-de-fer"]

  group "web" {
    count = 1

    network {
      
      port "web" {
        to = 3000
      }
    }

    task "web" {
      driver = "docker"
      config {
        image = "quay.io/cloud-projet/web"
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
      min = 1
      max = 10
    }
	}
}