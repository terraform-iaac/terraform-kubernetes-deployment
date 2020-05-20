locals {
  labels = var.custom_labels == null ? { app = var.name } : var.custom_labels
}