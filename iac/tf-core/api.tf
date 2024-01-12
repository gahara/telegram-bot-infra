module "api_resources" {
  source = "../tf-modules/api-resources"

  project = var.project
  env     = var.env
  policy_name = var.policy_name
  role_name = var.role_name

  # module specific
  for_each              = var.api_resources
  name                  = each.key
  handler               = each.value.handler
  runtime               = each.value.runtime
  timeout               = each.value.timeout
  memory_size           = each.value.memory_size
  package_type          = each.value.package_type
  environment_variables = each.value.environment_variables
  layer_create          = each.value.layer_create
  layer_powertools      = each.value.layer_powertools
  ssm_params            = each.value.ssm_params

  layer_bucket_name = module.s3_bucket_layer.bucket_name["layer-artifacts"]
}