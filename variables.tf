variable "name" {
  type        = string
  description = "(Required) Name of the deployment"
}
variable "namespace" {
  type        = string
  description = "(Optional) Namespace in which to create the deployment"
  default     = "default"
}
variable "deployment_annotations" {
  description = "Annotations for deployment"
  type        = map(string)
  default     = null
}
variable "template_annotations" {
  description = "Annotations for pod (template)"
  type        = map(string)
  default     = null
}
variable "image" {
  type        = string
  description = "(Required) Docker image name"
}
variable "image_pull_policy" {
  type        = string
  default     = "IfNotPresent"
  description = "One of Always, Never, IfNotPresent"
}
variable "args" {
  type        = list(string)
  description = "(Optional) Arguments to the entrypoint"
  default     = []
}
variable "command" {
  type        = list(string)
  description = "(Optional) Entrypoint array. Not executed within a shell"
  default     = []
}
variable "env" {
  type        = map(string)
  description = "(Optional) Name and value pairs to set in the container's environment"
  default     = {}
}
variable "env_field" {
  type        = map(string)
  description = "(Optional) Get field from k8s and add as environment variables to pods"
  default     = {}
}
variable "env_secret" {
  description = "(Optional) Get secret keys from k8s and add as environment variables to pods"
  default     = {}
}
variable "resources" {
/*  type = object({
    request_cpu    = optional(string)
    request_memory = optional(string)
    limit_cpu      = optional(string)
    limit_memory   = optional(string)
  })*/
  description = "(Optional) Compute Resources required by this container. CPU/RAM requests/limits"
  default     = {}
}
variable "internal_port" {
  type = list(object({
    name          = string
    internal_port = number
    host_port     = optional(string)
  }))
  description = "(Optional) List of ports to expose from the container"
  default     = []
}
variable "volume_mount" {
  type = list(object({
    volume_name = string
    mount_path  = string
    sub_path    = optional(string)
    read_only   = optional(string)
  }))
  description = "(Optional) Mount path from pods to volume"
  default     = []
}
variable "volume_nfs" {
  type = list(object({
    path_on_nfs  = string
    nfs_endpoint = string
    volume_name  = string
  }))
  description = "(Optional) Represents an NFS mounts on the host"
  default     = []
}
variable "volume_host_path" {
  type = list(object({
    volume_name  = string
    path_on_node = string
    type         = optional(string)
  }))
  description = "(Optional) Represents a directory from node on the host"
  default     = []
}
variable "volume_config_map" {
  type = list(object({
    volume_name = string
    name        = string
    mode        = optional(string)
    optional    = optional(string)
    items = optional(list(object({
      key  = string
      path = string
      mode = optional(string)
    })),[])
  }))
  description = "(Optional) The data stored in a ConfigMap object can be referenced in a volume of type configMap and then consumed by containerized applications running in a Pod"
  default     = []
}
variable "volume_empty_dir" {
  type = list(object({
    volume_name = string
    medium      = optional(string)
    size_limit  = optional(string)
  }))
  description = "(Optional) EmptyDir represents a temporary directory that shares a pod's lifetime"
  default     = []
}
variable "volume_gce_disk" {
  type = list(object({
    volume_name = string
    gce_disk    = optional(string)
    fs_type     = optional(string)
    partition   = optional(string)
    read_only   = optional(string)
  }))
  description = "(Optional) Represents an GCE Disk resource that is attached to a kubelet's host machine and then exposed to the pod"
  default     = []
}
variable "volume_secret" {
  type = list(object({
    volume_name  = string
    secret_name  = string
    default_mode = optional(string)
    optional     = optional(string)
    items = optional(list(object({
      key  = string
      path = string
      mode = optional(string)
    })),[])
  }))
  description = "(Optional) Create volume from secret"
  default     = []
}
variable "volume_aws_disk" {
  type = list(object({
    volume_name = string
    volume_id   = string
    fs_type     = optional(string)
    partition   = optional(string)
    read_only   = optional(string)
  }))
  description = "(Optional) Represents an AWS Disk resource that is attached to a kubelet's host machine and then exposed to the pod"
  default     = []
}
variable "volume_claim" {
  type = list(object({
    volume_name = string
    claim_name  = optional(string)
    read_only   = optional(string)
  }))
  description = "(Optional) Represents an Persistent volume Claim resource that is attached to a kubelet's host machine and then exposed to the pod"
  default     = []
}
variable "toleration" {
  type = list(object({
    effect             = optional(string)
    key                = optional(string)
    operator           = optional(string)
    toleration_seconds = optional(string)
    value              = optional(string)
  }))
  description = "(Optional) Pod node tolerations"
  default     = []
}
variable "hosts" {
  type = list(object({
    hostname = list(string)
    ip       = string
  }))
  description = "(Optional) Add /etc/hosts records to pods"
  default     = []
}
variable "security_context" {
/*  type = object({
    fs_group        = optional(string)
    run_as_group    = optional(string)
    run_as_user     = optional(string)
    run_as_non_root = optional(string)
  })*/
  description = "(Optional) SecurityContext holds pod-level security attributes and common container settings"
  default     = []
}
variable "security_context_container" {
/*  type = object({
    allow_privilege_escalation = optional(string)
    privileged                 = optional(string)
    read_only_root_filesystem  = optional(string)
    run_as_non_root            = optional(string)
    capabilities = optional(object({
      add  = optional(list(string))
      drop = optional(list(string))
    }),{})
  })*/
  description = "(Optional) Security context in pod."
  default     = []
}
variable "custom_labels" {
  description = "(Optional) Add custom label to pods"
  default     = null
  type        = map(string)
}
variable "tty" {
  description = "Whether this container should allocate a TTY for itself"
  type        = bool
  default     = true
}
variable "termination_grace_period_seconds" {
  type        = number
  description = "Duration in seconds the pod needs to terminate gracefully"
  default     = null
}
variable "service_account_token" {
  type        = bool
  description = "Indicates whether a service account token should be automatically mounted"
  default     = null
}
variable "service_account_name" {
  type        = string
  description = "(Optional) Is the name of the ServiceAccount to use to run this pod"
  default     = null
}
variable "restart_policy" {
  type        = string
  description = "Restart policy for all containers within the pod. One of Always, OnFailure, Never"
  default     = "Always"
}
variable "replicas" {
  type        = number
  description = "(Optional) Count of pods"
  default     = 1
}
variable "min_ready_seconds" {
  type        = number
  description = "(Optional) Field that specifies the minimum number of seconds for which a newly created Pod should be ready without any of its containers crashing, for it to be considered available"
  default     = null
}
variable "liveness_probe" {
/*  type = object({
    initial_delay_seconds = optional(string)
    period_seconds        = optional(string)
    timeout_seconds       = optional(string)
    success_threshold     = optional(string)
    failure_threshold     = optional(string)
    http_get = optional(object({
      path   = optional(string)
      port   = optional(string)
      scheme = optional(string)
      host   = optional(string)
      http_header = optional(list(object({
        name  = string
        value = string
      })))
    }))
    exec = optional(object({
      command = list(string)
    }))
    tcp_socket = optional(object({
      port = number
    }))
  })*/
  description = "(Optional) Periodic probe of container liveness. Container will be restarted if the probe fails. Cannot be updated. "
  default     = []
}
variable "readiness_probe" {
/*  type = object({
    initial_delay_seconds = optional(string)
    period_seconds        = optional(string)
    timeout_seconds       = optional(string)
    success_threshold     = optional(string)
    failure_threshold     = optional(string)
    http_get = optional(object({
      path   = optional(string)
      port   = optional(string)
      scheme = optional(string)
      host   = optional(string)
      http_header = optional(list(object({
        name  = string
        value = string
      })))
    }))
    exec = optional(object({
      command = list(string)
    }))
    tcp_socket = optional(object({
      port = number
    }))
  })*/
  description = "(Optional) Periodic probe of container service readiness. Container will be removed from service endpoints if the probe fails. Cannot be updated. "
  default     = []
}
variable "lifecycle_events" {
/*  type = object({
    pre_stop = optional(object({
      initial_delay_seconds = optional(string)
      period_seconds        = optional(string)
      timeout_seconds       = optional(string)
      success_threshold     = optional(string)
      failure_threshold     = optional(string)
      http_get = optional(object({
        path   = optional(string)
        port   = optional(string)
        scheme = optional(string)
        host   = optional(string)
        http_header = optional(list(object({
          name  = string
          value = string
        })))
      }))
      exec = object({
        command = list(string)
      })
      tcp_socket = object({
        port = number
      })
    }))
    post_start = optional(object({
      initial_delay_seconds = optional(string)
      period_seconds        = optional(string)
      timeout_seconds       = optional(string)
      success_threshold     = optional(string)
      failure_threshold     = optional(string)
      http_get = optional(object({
        path   = optional(string)
        port   = optional(string)
        scheme = optional(string)
        host   = optional(string)
        http_header = optional(list(object({
          name  = string
          value = string
        })))
      }))
      exec = optional(object({
        command = list(string)
      }))
      tcp_socket = optional(object({
        port = number
      }))
    }))
  })*/
  description = "(Optional) Actions that the management system should take in response to container lifecycle events"
  default     = []
}
variable "image_pull_secrets" {
  description = "(Optional) Specify list of pull secrets"
  type        = map(string)
  default     = {}
}
variable "node_selector" {
  description = "(Optional) Specify node selector for pod"
  type        = map(string)
  default     = null
}
variable "strategy_update" {
  type        = string
  description = "(Optional) Type of deployment. Can be 'Recreate' or 'RollingUpdate'"
  default     = "RollingUpdate"
}
variable "rolling_update" {
/*  type = object({
    max_surge       = optional(string)
    max_unavailable = optional(string)
  })*/
  description = "Rolling update config params. Present only if strategy_update = RollingUpdate"
  default     = []
}
variable "wait_for_rollout" {
  type        = bool
  description = "Wait for the deployment to successfully roll out."
  default     = true
}
variable "prevent_deploy_on_the_same_node" {
  description = "Pod pod_anti_affinity rule, which prevents deploy same pod on one node."
  type        = bool
  default     = false
}