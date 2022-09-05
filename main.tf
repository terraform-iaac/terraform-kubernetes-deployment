resource "kubernetes_deployment" "deploy_app" {
  wait_for_rollout = var.wait_for_rollout

  metadata {
    name        = var.name
    namespace   = var.namespace
    labels      = local.labels
    annotations = var.deployment_annotations
  }

  spec {
    min_ready_seconds = var.min_ready_seconds
    replicas          = var.replicas

    strategy {
      type = var.strategy_update
      dynamic "rolling_update" {
        for_each = flatten([var.rolling_update])
        content {
          max_surge       = lookup(rolling_update.value, "max_surge", "25%")
          max_unavailable = lookup(rolling_update.value, "max_unavailable", "25%")
        }
      }
    }

    selector {
      match_labels = local.labels
    }

    template {
      metadata {
        labels      = local.labels
        annotations = var.template_annotations
      }

      spec {
        termination_grace_period_seconds = var.termination_grace_period_seconds

        service_account_name            = var.service_account_name
        automount_service_account_token = var.service_account_token

        restart_policy = var.restart_policy
        
        dynamic "image_pull_secrets" {
          for_each = var.image_pull_secrets
          content {
            name = image_pull_secrets.value
          }
        }

        node_selector = var.node_selector

        dynamic "affinity" {
          for_each = var.prevent_deploy_on_the_same_node ? [{}] : []
          content {
            pod_anti_affinity {
              required_during_scheduling_ignored_during_execution {
                label_selector {
                  match_labels = local.labels
                }
                topology_key = "kubernetes.io/hostname"
              }
            }
          }
        }

        dynamic "toleration" {
          for_each = var.toleration
          content {
            effect             = lookup(toleration.value, "effect", null)
            key                = lookup(toleration.value, "key", null)
            operator           = lookup(toleration.value, "operator", null)
            toleration_seconds = lookup(toleration.value, "toleration_seconds", null)
            value              = lookup(toleration.value, "value", null)
          }
        }

        dynamic "host_aliases" {
          iterator = hosts
          for_each = var.hosts
          content {
            hostnames = hosts.value.hostname
            ip        = hosts.value.ip
          }
        }

        dynamic "volume" {
          for_each = var.volume_empty_dir
          content {
            empty_dir {}
            name = volume.value.volume_name
          }
        }

        dynamic "volume" {
          for_each = var.volume_nfs
          content {
            nfs {
              path   = volume.value.path_on_nfs
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
              type = lookup(volume.value, "type", null)
            }
            name = volume.value.volume_name
          }
        }

        dynamic "volume" {
          for_each = var.volume_config_map
          content {
            config_map {
              default_mode = volume.value.mode
              name         = volume.value.name
            }
            name = volume.value.volume_name
          }
        }

        dynamic "volume" {
          for_each = var.volume_gce_disk
          content {
            gce_persistent_disk {
              pd_name   = volume.value.gce_disk
              fs_type   = lookup(volume.value, "fs_type", null)
              partition = lookup(volume.value, "partition", null)
              read_only = lookup(volume.value, "read_only", null)
            }
            name = volume.value.volume_name
          }
        }

        dynamic "volume" {
          for_each = var.volume_secret
          content {
            secret {
              secret_name  = volume.value.secret_name
              default_mode = lookup(volume.value, "default_mode", null)
              optional     = lookup(volume.value, "optional", null)
              dynamic "items" {
                for_each = lookup(volume.value, "items", [])
                content {
                  key  = items.value.key
                  path = items.value.path
                  mode = lookup(items.value, "mode", null)
                }
              }
            }
            name = volume.value.volume_name
          }
        }

        dynamic "volume" {
          for_each = var.volume_aws_disk
          content {
            aws_elastic_block_store {
              fs_type   = lookup(volume.value, "fs_type", null)
              partition = lookup(volume.value, "partition", null)
              read_only = lookup(volume.value, "read_only", null)
              volume_id = volume.value.volume_id
            }
            name = volume.value.volume_name
          }
        }

        dynamic "volume" {
          for_each = var.volume_claim
          content {
            persistent_volume_claim {
              claim_name = lookup(volume.value, "claim_name", null)
              read_only  = lookup(volume.value, "read_only", null)
            }
            name = volume.value.volume_name
          }
        }

        dynamic "security_context" {
          for_each = flatten([var.security_context])
          content {
            fs_group        = lookup(security_context.value, "fs_group", null)
            run_as_group    = lookup(security_context.value, "run_as_group", null)
            run_as_user     = lookup(security_context.value, "run_as_user", null)
            run_as_non_root = lookup(security_context.value, "run_as_non_root", null)
          }
        }

        container {
          name              = var.name
          image             = var.image
          image_pull_policy = var.image_pull_policy
          args              = var.args
          command           = var.command

          dynamic "security_context" {
            for_each = flatten([var.security_context_container])
            content {
              allow_privilege_escalation = lookup(security_context.value, "allow_privilege_escalation", null)
              privileged                 = lookup(security_context.value, "privileged", null)
              read_only_root_filesystem  = lookup(security_context.value, "read_only_root_filesystem", null)
            }
          }
          dynamic "security_context" {
            for_each = flatten([var.security_context_capabilities])
            content {
              allow_privilege_escalation = false
              capabilities {
                add  = lookup(security_context.value, "add", [])
                drop = lookup(security_context.value, "drop", [])
              }
            }
          }

          dynamic "env" {
            for_each = local.env
            content {
              name  = env.value.name
              value = env.value.value
            }
          }

          dynamic "env" {
            for_each = local.env_field
            content {
              name = env.value.name
              value_from {
                field_ref {
                  field_path = env.value.field_path
                }
              }
            }
          }

          dynamic "env" {
            for_each = local.env_secret
            content {
              name = env.value.name
              value_from {
                secret_key_ref {
                  name = env.value.secret_name
                  key  = env.value.secret_key
                }
              }
            }
          }

          dynamic "resources" {
            for_each = length(var.resources) == 0 ? [] : [{}]
            content {
              requests = {
                cpu    = lookup(var.resources, "request_cpu", null)
                memory = lookup(var.resources, "request_memory", null)
              }
              limits = {
                cpu    = lookup(var.resources, "limit_cpu", null)
                memory = lookup(var.resources, "limit_memory", null)
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
            for_each = flatten([var.liveness_probe])
            content {
              initial_delay_seconds = lookup(liveness_probe.value, "initial_delay_seconds", null)
              period_seconds        = lookup(liveness_probe.value, "period_seconds", null)
              timeout_seconds       = lookup(liveness_probe.value, "timeout_seconds", null)
              success_threshold     = lookup(liveness_probe.value, "success_threshold", null)
              failure_threshold     = lookup(liveness_probe.value, "failure_threshold", null)

              dynamic "http_get" {
                for_each = contains(keys(liveness_probe.value), "http_get") ? [liveness_probe.value.http_get] : []

                content {
                  path   = lookup(http_get.value, "path", null)
                  port   = lookup(http_get.value, "port", null)
                  scheme = lookup(http_get.value, "scheme", null)
                  host   = lookup(http_get.value, "host", null)

                  dynamic "http_header" {
                    for_each = contains(keys(http_get.value), "http_header") ? http_get.value.http_header : []
                    content {
                      name  = http_header.value.name
                      value = http_header.value.value
                    }
                  }

                }
              }

              dynamic "exec" {
                for_each = contains(keys(liveness_probe.value), "exec") ? [liveness_probe.value.exec] : []

                content {
                  command = exec.value.command
                }
              }

              dynamic "tcp_socket" {
                for_each = contains(keys(liveness_probe.value), "tcp_socket") ? [liveness_probe.value.tcp_socket] : []
                content {
                  port = tcp_socket.value.port
                }
              }
            }
          }

          dynamic "readiness_probe" {
            for_each = flatten([var.readiness_probe])
            content {
              initial_delay_seconds = lookup(readiness_probe.value, "initial_delay_seconds", null)
              period_seconds        = lookup(readiness_probe.value, "period_seconds", null)
              timeout_seconds       = lookup(readiness_probe.value, "timeout_seconds", null)
              success_threshold     = lookup(readiness_probe.value, "success_threshold", null)
              failure_threshold     = lookup(readiness_probe.value, "failure_threshold", null)

              dynamic "http_get" {
                for_each = contains(keys(readiness_probe.value), "http_get") ? [readiness_probe.value.http_get] : []

                content {
                  path   = lookup(http_get.value, "path", null)
                  port   = lookup(http_get.value, "port", null)
                  scheme = lookup(http_get.value, "scheme", null)
                  host   = lookup(http_get.value, "host", null)

                  dynamic "http_header" {
                    for_each = contains(keys(http_get.value), "http_header") ? http_get.value.http_header : []
                    content {
                      name  = http_header.value.name
                      value = http_header.value.value
                    }
                  }

                }
              }

              dynamic "exec" {
                for_each = contains(keys(readiness_probe.value), "exec") ? [readiness_probe.value.exec] : []

                content {
                  command = exec.value.command
                }
              }

              dynamic "tcp_socket" {
                for_each = contains(keys(readiness_probe.value), "tcp_socket") ? [readiness_probe.value.tcp_socket] : []
                content {
                  port = tcp_socket.value.port
                }
              }
            }
          }

          dynamic "lifecycle" {
            for_each = flatten([var.lifecycle_events])
            content {
              dynamic "pre_stop" {
                for_each = contains(keys(lifecycle.value), "pre_stop") ? [lifecycle.value.pre_stop] : []

                content {
                  dynamic "http_get" {
                    for_each = contains(keys(pre_stop.value), "http_get") ? [pre_stop.value.http_get] : []

                    content {
                      path   = lookup(http_get.value, "path", null)
                      port   = lookup(http_get.value, "port", null)
                      scheme = lookup(http_get.value, "scheme", null)
                      host   = lookup(http_get.value, "host", null)

                      dynamic "http_header" {
                        for_each = contains(keys(http_get.value), "http_header") ? http_get.value.http_header : []
                        content {
                          name  = http_header.value.name
                          value = http_header.value.value
                        }
                      }

                    }
                  }

                  dynamic "exec" {
                    for_each = contains(keys(pre_stop.value), "exec") ? [pre_stop.value.exec] : []

                    content {
                      command = exec.value.command
                    }
                  }

                  dynamic "tcp_socket" {
                    for_each = contains(keys(pre_stop.value), "tcp_socket") ? [pre_stop.value.tcp_socket] : []
                    content {
                      port = tcp_socket.value.port
                    }
                  }
                }
              }

              dynamic "post_start" {
                for_each = contains(keys(lifecycle.value), "post_start") ? [lifecycle.value.post_start] : []

                content {
                  dynamic "http_get" {
                    for_each = contains(keys(post_start.value), "http_get") ? [post_start.value.http_get] : []

                    content {
                      path   = lookup(http_get.value, "path", null)
                      port   = lookup(http_get.value, "port", null)
                      scheme = lookup(http_get.value, "scheme", null)
                      host   = lookup(http_get.value, "host", null)

                      dynamic "http_header" {
                        for_each = contains(keys(http_get.value), "http_header") ? http_get.value.http_header : []
                        content {
                          name  = http_header.value.name
                          value = http_header.value.value
                        }
                      }

                    }
                  }

                  dynamic "exec" {
                    for_each = contains(keys(post_start.value), "exec") ? [post_start.value.exec] : []

                    content {
                      command = exec.value.command
                    }
                  }

                  dynamic "tcp_socket" {
                    for_each = contains(keys(post_start.value), "tcp_socket") ? [post_start.value.tcp_socket] : []
                    content {
                      port = tcp_socket.value.port
                    }
                  }
                }
              }

            }
          }

          tty = var.tty
        }
      }
    }
  }
}