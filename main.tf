resource "kubernetes_deployment" "deploy_app" {
  metadata {
    name = var.name
    #namespace = var.namespace
    annotations = {
      "field.cattle.io/publicEndpoints" = ""
    }
  }
  spec {
    replicas = var.replicas
    selector {
      match_labels = {
        app = var.name
      }
    }
    template {
      metadata {
        labels = {
          app = var.name
          logs = var.filebeat_exclude
        }
      }
      spec {
        service_account_name = var.service_account_name
        automount_service_account_token = var.service_account_token
        container {
          image = var.image
          name = var.name
          args = var.args
          dynamic "security_context" {
            iterator = security_context
            for_each = var.security_context
            content {
              run_as_user = security_context.value.user_id
            }
          }
          dynamic "env" {
            iterator = env
            for_each = var.env
            content {
              name = env.value.name
              value = env.value.value
            }
          }
          dynamic "port" {
            iterator = port
            for_each = var.internal_port
            content {
              container_port = port.value.internal_port
            }
          }
          dynamic "volume_mount" {
            iterator = volume_mount
            for_each = var.volume_mount
            content {
              mount_path = volume_mount.value.mount_path
              sub_path = lookup(volume_mount.value, "sub_path", null)
              name = volume_mount.value.volume_name
            }
          }
          tty = "true"
        }
        dynamic "host_aliases"{
          iterator = hosts
          for_each = var.hosts
          content {
            hostnames = ["${hosts.value.hostname}"]
            ip = hosts.value.ip
          }
        }
        dynamic "volume" {
          iterator = volume
          for_each = var.volume_efs
          content {
            nfs {
              path = volume.value.path_on_efs
              server = "${volume.value.efs_id}.efs.${var.region}.amazonaws.com"
            }
            name = volume.value.volume_name
          }
        }

        dynamic "volume" {
          iterator = volume
          for_each = var.volume_node
          content {
            host_path {
              path = volume.value.path_on_node
              type = lookup(volume.value, "type", null )
            }
            name = volume.value.volume_name
          }
        }
        dynamic "volume" {
          iterator = volume
          for_each = var.volume_map
          content {
            config_map {
              default_mode = volume.value.mode
              name = volume.value.name
            }
            name = volume.value.volume_name
          }
        }
        restart_policy = "Always"
      }
    }
  }
  lifecycle {
    ignore_changes = [
      metadata.0.annotations["field.cattle.io/publicEndpoints"]
    ]
  }
}