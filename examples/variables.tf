variable "app_name" {
  default = "jenkins"
}

variable "app_namespace" {
  default = "jenkins-ci"
}

variable "image" {
  default = "jenkins/jenkins:latest"
}

variable "ports" {
  default = [
    {
      name = "web-access"
      internal_port = "8080"
    }
  ]
}

variable "volume_data" {
  default = "data"
}

variable "volume_logs" {
  default = "logs-from-node"
}

variable "volume_tmp" {
  default = "tmp-from-node"
}

variable "volume_config" {
  default = "jenkins-configmap"
}