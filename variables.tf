variable "name" {
  type        = string
  description = "(Required) Name of the deployment"
}
variable "namespace" {
  type        = string
  description = "(Optional) Namespace in which to create the deployment"
  default     = "default"
}
variable "image" {
  type        = string
  description = "(Required) Docker image name"
}
variable "image_pull_policy" {
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
  description = " (Optional) Entrypoint array. Not executed within a shell"
  default     = []
}
variable "env" {
  type        = list(object({ name = string, value = string }))
  description = "(Optional) Name and value pairs to set in the container's environment"
  default     = []
}
variable "env_field" {
  type        = list(object({ name = string, field_path = string }))
  description = "(Optional) Get field from k8s and add as environment variables to pods"
  default     = []
}
variable "env_secret" {
  description = "(Optional) Get secret keys from k8s and add as environment variables to pods"
  type        = list(object({ name = string, secret_name = string, secret_key = string }))
  default     = []
}
variable "resources" {
  description = "(Optional) Compute Resources required by this container. CPU/RAM requests/limits"
  default     = {}
}
variable "internal_port" {
  description = "(Optional) List of ports to expose from the container"
  default     = []
}
variable "volume_mount" {
  description = "(Optional) Mount path from pods to volume"
  default     = []
}
variable "volume_nfs" {
  type        = list(object({ path_on_nfs = string, nfs_endpoint = string, volume_name = string }))
  description = "(Optional) Represents an NFS mounts on the host"
  default     = []
}
variable "volume_host_path" {
  description = "(Optional) Represents a directory from node on the host"
  default     = []
}
variable "volume_config_map" {
  type        = list(object({ mode = string, name = string, volume_name = string }))
  description = "(Optional) The data stored in a ConfigMap object can be referenced in a volume of type configMap and then consumed by containerized applications running in a Pod"
  default     = []
}
variable "volume_gce_disk" {
  description = "(Optional) Represents an GCE Disk resource that is attached to a kubelet's host machine and then exposed to the pod"
  default     = []
}
variable "volume_aws_disk" {
  description = "(Optional) Represents an AWS Disk resource that is attached to a kubelet's host machine and then exposed to the pod"
  default     = []
}
variable "volume_claim" {
  description = "(Optional) Represents an Persistent volume Claim resource that is attached to a kubelet's host machine and then exposed to the pod"
  default     = []
}
variable "hosts" {
  type        = list(object({ hostname = list(string), ip = string }))
  description = "(Optional) Add /etc/hosts records to pods"
  default     = []
}
variable "security_context" {
  description = "(Optional) Set startup user_id, when pods start"
  default     = []
}
variable "custom_labels" {
  description = "(Optional) Add custom label to pods"
  default     = null
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
  description = "(Optional) Periodic probe of container liveness. Container will be restarted if the probe fails. Cannot be updated. "
  default     = []
}
variable "readiness_probe" {
  description = "(Optional) Periodic probe of container service readiness. Container will be removed from service endpoints if the probe fails. Cannot be updated. "
  default     = []
}
variable "lifecycle_events" {
  description = "(Optional) Actions that the management system should take in response to container lifecycle events"
  default     = []
}
variable "node_selector" {
  description = "(Optional) Specify node selector for pod"
  type        = map(string)
  default     = null
}
variable "security_context_capabilities" {
  description = "(Optional) Security context in pod. Only capabilities."
  default     = []
}
variable "strategy_update" {
  description = "(Optional) Type of deployment. Can be 'Recreate' or 'RollingUpdate'"
  default     = "RollingUpdate"
}
variable "wait_for_rollout" {
  default = true
}