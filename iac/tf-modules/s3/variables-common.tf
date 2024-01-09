#To organize files inside S3
variable "project" {
  type = string
}

variable "env" {
  type = string
}

locals {
  resource_name_prefix = "${title(var.project)}-${title(var.env)}"
}