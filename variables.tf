variable "name" {
  description = "(Required) Deployment name"
}
variable "namespace" {
  description = "(Required) K8S namespace where deploy app"
}
variable "image" {
  description = "(Required) Docker image for app"
}
variable "volume_nfs" {
  description = "(Optional) Attach NFS"
  default = []
}
variable "volume_host_path" {
  description = "(Optional) Attach a file or directory from the host node’s filesystem"
  default = []
}
variable "volume_config_map" {
  description = "(Optional) The data stored in a ConfigMap object can be referenced in a volume of type configMap and then consumed by containerized applications running in a Pod"
  default = []
}
variable "volume_gce_disk" {
  description = "(Optional) Create volume from google disk to pod"
  default = []
}
variable "volume_mount" {
  description = "(Optional) Mount path from pods to volume"
  default = []
}
variable "env" {
  description = "(Optional) Add environment variables to pods."
  default = []
}
variable "env_field" {
  description = "(Optional) Get field from k8s and add as environment variables to pods"
  default = []
}
variable "hosts" {
  description = "(Optional) Add /etc/hosts records to pods"
  default = []
}
variable "internal_port" {
  description = "(Optional) Expose port in pods"
  default = []
}
variable "security_context" {
  description = "(Optional) Set startup user_id, when pods start"
  default = []
}
variable "custom_label" {
  description = "(Optional) Add custom label to pods"
  default = null
}
variable "args" {
  description = "(Optional) Arguments to the entrypoint."
  default = []
}
variable "service_account_token" {
  description = "Indicates whether a service account token should be automatically mounted"
  default = null
}
variable "service_account_name" {
  description = "(Optional) Is the name of the ServiceAccount to use to run this pod"
  default = null
}
variable "restart_policy" {
  description = "Restart policy for all containers within the pod. One of Always, OnFailure, Never"
  default = "Always"
}
variable "replicas" {
  description = "(Optional) Count of pods"
  default = "1"
}
variable "min_ready_seconds" {
  description = "(Optional) Field that specifies the minimum number of seconds for which a newly created Pod should be ready without any of its containers crashing, for it to be considered available  "
  default = null
}
variable "resources" {
  description = "(Optional) Limit resources by cpu or memory for pods"
  default = []
}