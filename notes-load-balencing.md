job "cloud-app" {

  datacenters = ["homme-de-fer"]

  group "app" {

​    count = 1

​    network {

​      port "web" {

​        static = 3000

​      }

​    }

​    task "web" {

​      driver = "docker"

​      config {

​        image = "quay.io/cloud-projet/web"

​        ports = ["web"]

​      }

​      service {

​        name = "web"

​        port = "web"

​        check {

​          name     = "alive"

​          type     = "http"

​          protocol = "http"

​          path     = "/"

​          interval = "10s"

​          timeout  = "2s"

​        }

​      }

​      resources {

​        cpu    = 100

​        memory = 128

​      }

​    }

​    scaling {

​      enabled = true

​      min = 1

​      max = 5

​      policy "cpu" {

​        up {

​          trigger = {

​            metric          = "cpu.user.percent"

​            threshold       = 70

​            time            = "60s"

​            evaluation_type = "avg"

​          }

​          action = {

​            type = "scale"

​            count = 1

​          }

​        }

​        down {

​          trigger = {

​            metric          = "cpu.user.percent"

​            threshold       = 30

​            time            = "60s"

​            evaluation_type = "avg"

​          }

​          action = {

​            type = "scale"

​            count = -1

​          }

​        }

​      }

​    }

  }

}



Changer le port dynamiquement

https://developer.hashicorp.com/nomad/tutorials/load-balancing/load-balancing-haproxy