variable "region" {
  description = "Region"
  type        = string
}

variable "default_tags" {
  type        = map(string)
  description = "Default tags for resources"
}

variable "project" {
  type = string
}

variable "env" {
  type = string
}

variable "policy_name" {
  type = string
}

variable "role_name" {
  type = string
}

variable "resource_region" {
  type        = string
  description = "Region in which create resources"
}