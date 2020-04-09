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

variable "volume-data" {
  default = "data"
}

variable "volume-logs" {
  default = "logs_from_node"
}

variable "volume-tmp" {
  default = "tmp-from-node"
}

variable "volume-config" {
  default = "jenkins-configmap"
}