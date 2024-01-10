data "external" "env" {
  program = ["${path.module}/collect-env-params.sh"]
}

locals {
  param_key_prefix   = "${lower(var.project)}/${lower(var.env)}/${lower(var.name)}"
  param_value_prefix = "${lower(var.project)}_${lower(var.env)}_${lower(var.name)}"
  ssm_params         = (var.ssm_params == null) ? {} : var.ssm_params
}

data "aws_kms_key" "main" {
  key_id = "alias/aws/lambda"
}

resource "aws_ssm_parameter" "main" {
  for_each = var.ssm_params # replace with local.ssm_params
  name     = "/${local.param_key_prefix}/${each.key}"
  type     = each.value.type

  # 1st preference: if value is defined in the tfpars.
  # 2nd preference: if value is defined in the env.
  # If value is missing in both the places. TF plan fails.
  value = try(length(each.value.value) > 0, false) ? each.value.value : data.external.env.result[upper(replace("TF_VAR_${each.key}", "-", "_"))]

  depends_on = [data.external.env]
}

data "aws_ssm_parameters_by_path" "main" {
  path = "/${local.param_key_prefix}"
}