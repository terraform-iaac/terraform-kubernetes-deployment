resource "kubernetes_deployment" "deploy_app" {
  metadata {
    name = var.name
    namespace = var.namespace
    labels = local.labels
  }
  spec {
    min_ready_seconds = var.min_ready_seconds
    replicas = var.replicas
    selector {
      match_labels = local.labels
    }
    template {
      metadata {
        labels = local.labels
      }
      spec {
        dynamic "security_context" {
          for_each = var.security_context
          content {
            fs_group = lookup(security_context.value, "fs_group", null )
            run_as_group = lookup(security_context.value, "group_id", null)
            run_as_user = lookup(security_context.value, "user_id", null)
            run_as_non_root = lookup(security_context.value, "as_non_root", null)

          }
        }
        service_account_name = var.service_account_name
        automount_service_account_token = var.service_account_token
        container {
          image = var.image
          name = var.name
          args = var.args
          dynamic "env" {
            for_each = var.env
            content {
              name = env.value.name
              value = env.value.value
            }
          }
          dynamic "env" {
            for_each = var.env_field
            content {
              name = env.value.name
              value_from {
                field_ref {
                  field_path = env.value.value
                }
              }
            }
          }
          dynamic "resources" {
            for_each = var.resources
            content {
              limits {
                cpu = lookup(resources.value, "cpu", null)
                memory = lookup(resources.value, "memory", null)
              }
            }
          }
          dynamic "port" {
            for_each = var.internal_port
            content {
              container_port = port.value.internal_port
              name = substr(port.value.name, 0, 14)
              host_port = lookup(port.value, "host_port", null)
            }
          }
          dynamic "volume_mount" {
            for_each = var.volume_mount
            content {
              mount_path = volume_mount.value.mount_path
              sub_path = lookup(volume_mount.value, "sub_path", null)
              name = volume_mount.value.volume_name
              read_only = lookup(volume_mount.value, "read_only", false)
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
          for_each = var.volume_nfs
          content {
            nfs {
              path = volume.value.path_on_nfs
              server = volume.value.nfs_endpoint
            }
            name = volume.value.volume_name
          }
        }
        dynamic "volume" {
          for_each = var.volume_host_path
          content {
            host_path {
              path = volume.value.path_on_node
              type = lookup(volume.value, "type", null )
            }
            name = volume.value.volume_name
          }
        }
        dynamic "volume" {
          for_each = var.volume_config_map
          content {
            config_map {
              default_mode = volume.value.mode
              name = volume.value.name
            }
            name = volume.value.volume_name
          }
        }
        dynamic "volume" {
          for_each = var.volume_gce_disk
          content {
            gce_persistent_disk {
              pd_name = volume.value.gce_disk
              fs_type = lookup(volume.value, "fs_type", null )
              partition = lookup(volume.value, "partition", null )
              read_only = lookup(volume.value, "read_only", null)
            }
            name = volume.value.volume_name
          }
        }
        restart_policy = var.restart_policy
      }
    }
  }
}