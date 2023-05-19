job "api" {
  datacenters = ["homme-de-fer"]

  group "api" {
    count = 2

    network {
      port "api" {
				to = 8080
        host_network = "internal"
			}
    }

    task "api" {
      driver = "docker"
      config {
        force_pull = true
        image = "quay.io/cloud-projet/api:$version"
        ports = ["api"]
      }

      env {
        PORT    = "${NOMAD_PORT_api}"
        NODE_IP = "${NOMAD_IP_api}"
				AWS_ACCESS_KEY_ID=$aws_access_key_id
				AWS_SECRET_ACCESS_KEY=$aws_secret_access_key
				S3_BUCKET_NAME=$s3_bucket_name
				S3_ENDPOINT_URL=$s3_endpoint_url
				CELERY_BROKER_URL=$celery_broker_url
      }

			service {
				name = "api"
				port = "api"

				check {
					type     = "http"
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