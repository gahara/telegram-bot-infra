locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name

  resource_name_prefix = "${title(var.project)}-${title(var.env)}"
  name                 ="${local.resource_name_prefix}-${title(var.name)}"

  layer_zip_file_name  = "${local.name}-layer.zip"
  tmp_layer_path = "../temp/${local.name}"

  lambda_src_dir = "../../functions/${var.name}"
  lambda_zip_file_name = "${local.name}-func.zip"
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}