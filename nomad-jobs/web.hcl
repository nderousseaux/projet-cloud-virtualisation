job "cloud-app" {
  datacenters = ["homme-de-fer"]

  group "app" {
    count = 1

    network {
      port "web" {
        static = 3000
      }
    }

    task "web" {
      driver = "docker"
      config {
        image = "quay.io/cloud-projet/web"
        ports = ["web"]
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
        cpu    = 100
        memory = 128
      }
    }
	}
}