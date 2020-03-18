variable "name" {}
#variable "namespace" {}
variable "image" {}

variable "region" {
  default = []
}

variable "volume_efs" {
  default = []
}

variable "filebeat_exclude" {
  default = null
}
variable "env" {
  default = []
}
variable "hosts" {
  default = []
}
variable "internal_port" {
  default = []
}
variable "volume_mount" {
  default = []
}
variable "replicas" {
  default = "1"
}
variable "volume_node" {
  default = []
}
variable "volume_map" {
  default = []
}
variable "security_context" {
  default = []
}
variable "args" {
  default = []
}

variable "service_account_token" {
  default = null
}
variable "service_account_name" {
  default = null
}