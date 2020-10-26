resource "kubernetes_deployment" "deploy_app" {
  metadata {
    name      = var.name
    namespace = var.namespace
    labels    = local.labels
  }

  spec {
    min_ready_seconds = var.min_ready_seconds
    replicas          = var.replicas

    strategy {
      type = var.strategy_update
    }

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
            fs_group        = lookup(security_context.value, "fs_group", null )
            run_as_group    = lookup(security_context.value, "group_id", null)
            run_as_user     = lookup(security_context.value, "user_id", null)
            run_as_non_root = lookup(security_context.value, "as_non_root", null)

          }
        }

        service_account_name            = var.service_account_name
        automount_service_account_token = var.service_account_token

        container {

          image             = var.image
          name              = var.name
          args              = var.args
          command           = var.command
          image_pull_policy = var.image_pull_policy

          dynamic "env" {
            for_each = var.env
            content {
              name   = env.value.name
              value  = env.value.value
            }
          }

          dynamic "env" {
            for_each = var.env_field
            content {
              name   = env.value.name
              value_from {
                field_ref {
                  field_path = env.value.field_path
                }
              }
            }
          }

          dynamic "env" {
            for_each = var.env_secret
            content {
              name   = env.value.name
              value_from {
                secret_key_ref {
                  name = env.value.secret_name
                  key  = env.value.secret_key
                }
              }
            }
          }

          dynamic "security_context" {
            for_each = var.security_context_capabilities
            content {
              allow_privilege_escalation = false
              capabilities {
                add  = lookup(security_context.value, "add", [] )
                drop = lookup(security_context.value, "drop", [] )
              }
            }
          }

          dynamic "resources" {
            for_each = var.resources
            content {
              requests {
                cpu    = lookup(resources.value, "request_cpu", null)
                memory = lookup(resources.value, "request_memory", null)
              }
              limits {
                cpu    = lookup(resources.value, "limit_cpu", null)
                memory = lookup(resources.value, "limit_memory", null)
              }
            }
          }

          dynamic "port" {
            for_each = var.internal_port
            content {
              container_port = port.value.internal_port
              name           = substr(port.value.name, 0, 14)
              host_port      = lookup(port.value, "host_port", null)
            }
          }

          dynamic "volume_mount" {
            for_each = var.volume_mount
            content {
              mount_path = volume_mount.value.mount_path
              sub_path   = lookup(volume_mount.value, "sub_path", null)
              name       = volume_mount.value.volume_name
              read_only  = lookup(volume_mount.value, "read_only", false)
            }
          }

          dynamic "liveness_probe" {
            for_each = var.liveness_probe
            content {
              failure_threshold     = lookup(liveness_probe.value, "failure_threshold", null)
              initial_delay_seconds = lookup(liveness_probe.value, "initial_delay_seconds", null)
              period_seconds        = lookup(liveness_probe.value, "period_seconds", null)
              success_threshold     = lookup(liveness_probe.value, "success_threshold", null)
              timeout_seconds       = lookup(liveness_probe.value, "timeout_seconds", null)

              dynamic "http_get"{
                for_each = lookup(liveness_probe.value, "http_get", [])
                content {
                  path   = lookup(http_get.value, "path", null)
                  port   = lookup(http_get.value, "port", null)
                  scheme = lookup(http_get.value, "scheme", null)
                  host   = lookup(http_get.value, "host", null)

                  dynamic "http_header" {
                    for_each = lookup(http_get.value, "http_header", [])
                    content {
                      name   = lookup(http_header.value, "name", null)
                      value  = lookup(http_header.value, "value", null)
                    }
                  }
                }
              }

              dynamic "tcp_socket" {
                for_each = lookup(liveness_probe.value, "tcp_socket", null) == null ? [] : [{}]
                content {
                  port   = liveness_probe.value.tcp_socket_port
                }
              }

            }
          }

          dynamic "readiness_probe" {
            for_each = var.readiness_probe
            content {
              failure_threshold     = lookup(readiness_probe.value, "failure_threshold", null)
              initial_delay_seconds = lookup(readiness_probe.value, "initial_delay_seconds", null)
              period_seconds        =  lookup(readiness_probe.value, "period_seconds", null)
              success_threshold     = lookup(readiness_probe.value, "success_threshold", null)
              timeout_seconds       = lookup(readiness_probe.value, "timeout_seconds", null)

              dynamic "http_get"{
                for_each = lookup(readiness_probe.value, "http_get", [])
                content {
                  path   = lookup(http_get.value, "path", null)
                  port   = lookup(http_get.value, "port", null)
                  scheme = lookup(http_get.value, "scheme", null)
                  host   = lookup(http_get.value, "host", null)

                  dynamic "http_header" {
                    for_each = lookup(http_get.value, "http_header", [])
                    content {
                      name   = lookup(http_header.value, "name", null)
                      value  = lookup(http_header.value, "value", null)
                    }
                  }

                }
              }

              dynamic "tcp_socket" {
                for_each = lookup(readiness_probe.value, "tcp_socket", null) == null ? [] : [{}]
                content {
                  port   = readiness_probe.value.tcp_socket_port
                }
              }

            }
          }

          dynamic "lifecycle"{
            for_each = var.lifecycle_events
            content {

              dynamic "pre_stop"{
                for_each = lookup(lifecycle.value, "pre_stop", [])

                content {
                  exec {
                    command = lookup(pre_stop.value, "exec_command", null)
                  }

                  dynamic "http_get"{
                    for_each = lookup(pre_stop.value, "http_get", [])
                    content {
                      path   = lookup(http_get.value, "path", null)
                      port   = lookup(http_get.value, "port", null)
                      scheme = lookup(http_get.value, "scheme", null)
                      host   = lookup(http_get.value, "host", null)

                      dynamic "http_header" {
                        for_each = lookup(http_get.value, "http_header", [])
                        content {
                          name   = lookup(http_header.value, "name", null)
                          value  = lookup(http_header.value, "value", null)
                        }
                      }
                    }
                  }

                  dynamic "tcp_socket" {
                    for_each = lookup(lifecycle.value, "tcp_socket", null) == null ? [] : [{}]
                    content {
                      port   = lifecycle.value.tcp_socket_port
                    }
                  }

                }
              }

              dynamic "post_start"{
                for_each = lookup(lifecycle.value, "post_start", [])

                content {
                  exec {
                    command = lookup(post_start.value, "exec_command", null)
                  }

                  dynamic "http_get"{
                    for_each = lookup(post_start.value, "http_get", [])
                    content {
                      path   = lookup(http_get.value, "path", null)
                      port   = lookup(http_get.value, "port", null)
                      scheme = lookup(http_get.value, "scheme", null)
                      host   = lookup(http_get.value, "host", null)

                      dynamic "http_header" {
                        for_each = lookup(http_get.value, "http_header", [])
                        content {
                          name   = lookup(http_header.value, "name", null)
                          value  = lookup(http_header.value, "value", null)
                        }
                      }

                    }
                  }

                  dynamic "tcp_socket" {
                    for_each = lookup(lifecycle.value, "tcp_socket", null) == null ? [] : [{}]
                    content {
                      port   = lifecycle.value.tcp_socket_port
                    }
                  }

                }

              }

            }
          }

          tty = var.tty
        }

        node_selector = var.node_selector
        dynamic "host_aliases"{
          iterator = hosts
          for_each = var.hosts
          content {
            hostnames = hosts.value.hostname
            ip        = hosts.value.ip
          }
        }

        dynamic "volume" {
          for_each   = var.volume_nfs
          content {
            nfs {
              path   = volume.value.path_on_nfs
              server = volume.value.nfs_endpoint
            }
            name     = volume.value.volume_name
          }
        }

        dynamic "volume" {
          for_each = var.volume_host_path
          content {
            host_path {
              path = volume.value.path_on_node
              type = lookup(volume.value, "type", null )
            }
            name   = volume.value.volume_name
          }
        }

        dynamic "volume" {
          for_each         = var.volume_config_map
          content {
            config_map {
              default_mode = volume.value.mode
              name         = volume.value.name
            }
            name           = volume.value.volume_name
          }
        }

        dynamic "volume" {
          for_each      = var.volume_gce_disk
          content {
            gce_persistent_disk {
              pd_name   = volume.value.gce_disk
              fs_type   = lookup(volume.value, "fs_type", null )
              partition = lookup(volume.value, "partition", null )
              read_only = lookup(volume.value, "read_only", null)
            }
            name        = volume.value.volume_name
          }
        }

        dynamic "volume" {
          for_each      = var.volume_aws_disk
          content {
            aws_elastic_block_store {
              fs_type   = lookup(volume.value, "fs_type", null )
              partition = lookup(volume.value, "partition", null )
              read_only = lookup(volume.value, "read_only", null)
              volume_id = volume.value.volume_id
            }
            name        = volume.value.volume_name
          }
        }

        restart_policy = var.restart_policy

      }
    }
  }
  wait_for_rollout = var.wait_for_rollout
}