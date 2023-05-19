job "worker" {
  datacenters = ["homme-de-fer"]



  group "worker" {
    count = 1

    task "worker" {
      driver = "docker"
      config {
        image = "quay.io/cloud-projet/worker:$version"
      }

      env {
				AWS_ACCESS_KEY_ID=$aws_access_key_id
				AWS_SECRET_ACCESS_KEY=$aws_secret_access_key
				S3_BUCKET_NAME=$s3_bucket_name
				S3_ENDPOINT_URL=$s3_endpoint_url
				CELERY_BROKER_URL=$celery_broker_url
      }

			service {
				name = "worker"
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