module "deploy" {
  source        = "../"
  name          = var.app_name
  namespace     = var.app_namespace
  image         = var.image
  internal_port = var.ports
  volume_nfs = [
    {
      path_on_nfs  = "/"
      nfs_endpoint = "10.10.0.100"
      volume_name  = var.volume_data
    }
  ]
  volume_host_path = [
    {
      volume_name  = var.volume_logs
      path_on_node = "/var/log"
    },
    {
      volume_name  = var.volume_tmp
      path_on_node = "/tmp"
    }
  ]
  volume_mount = [
    {
      mount_path  = "/var/jenkins_home"
      sub_path    = "jenkins"
      volume_name = var.volume_data
    },
    {
      mount_path  = "/logs"
      volume_name = var.volume_logs
    },
    {
      mount_path  = "/tmps"
      volume_name = var.volume_tmp
    },
    {
      mount_path  = "/var/jenkins_home/config.conf"
      volume_name = var.volume_config
      sub_path    = "key1" // Key from configmap
    }
  ]
  volume_config_map = [
    {
      mode        = "0777"           // Must be a value between 0 and 0777. Defaults to 0644
      name        = "config-jenkins" // Config map name
      volume_name = var.volume_config
    }
  ]
  readiness_probe = {
    http_get = {
      path   = "/healthcheck"
      port   = 80
      scheme = "HTTP"
      http_header = [
        {
          name  = "test"
          value = "test"
        },
        {
          name  = "tes"
          value = "asd"
        }
      ]
    }
    success_threshold     = 1
    failure_threshold     = 3
    initial_delay_seconds = 10
    period_seconds        = 30
    timeout_seconds       = 3
  }
}