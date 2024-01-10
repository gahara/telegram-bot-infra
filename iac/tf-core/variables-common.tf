variable "api_resources" {
  type = map(object({
    handler               = string
    runtime               = string
    timeout               = number
    memory_size           = number
    package_type          = string
    environment_variables = map(string)
    layer_create          = bool
    layer_powertools      = optional(string)
    ssm_params            = optional(map(object({
      type  = string
      value = optional(string)
    })))
  }))
}