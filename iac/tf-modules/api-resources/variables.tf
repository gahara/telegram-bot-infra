variable "project" {
  type = string
}

variable "env" {
  type = string
}

variable "name" {
  type = string
}

variable "layer_create" {
  type    = bool
  default = false
}

variable "layer_bucket_name" {
  type = string
}

variable "runtime" {
  type    = string
  default = "python3.11"
}

variable "handler" {
  type    = string
  default = "lambda_function.lambda_handler"
}

variable "memory_size" {
  type    = number
  default = 256
}

variable "package_type" {
  type    = string
  default = "Zip"
}

variable "timeout" {
  type    = number
  default = 300
}

variable "layer_powertools" {
  type = string # to use pre-existing layer
}

variable "environment_variables" {
  type = map(string)
}

variable "ssm_params" {
  type = map(object({
    type  = string
    value = optional(string)
  }))
  default = {}
}

variable "policy_name" {
  type = string
  default = "bot_policy"
}

variable "role_name" {
  type = string
  default = "bot_role"
}