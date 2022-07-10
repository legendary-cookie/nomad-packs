job [[ template "job_name" . ]] {
  [[ template "region" . ]]
  datacenters = [[ .httpbin.datacenters  | toJson ]]
  type = "service"

  group "app" {
    count = [[ .httpbin.count ]]

    network {
      port "http" {
        to = 80
      }
    }

    [[ if .httpbin.register_consul_service ]]
    service {
      name = "[[ .httpbin.consul_service_name ]]"
      tags = [[ .httpbin.consul_service_tags | toJson ]]
      port = "http"

      check {
        name     = "alive"
        type     = "http"
        path     = "/"
        interval = "10s"
        timeout  = "2s"
      }
    }
    [[ end ]]

    restart {
      attempts = 2
      interval = "30m"
      delay    = "15s"
      mode     = "fail"
    }

    task "server" {
      driver = "docker"

      config {
        image = "kennethreitz/httpbin"
        ports = ["http"]
      }

      resources {
        cpu    = 100
        memory = 128
      }
    }
  }
}
