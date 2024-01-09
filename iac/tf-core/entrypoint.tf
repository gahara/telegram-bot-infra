locals {
  resource_name_prefix = "${title(var.project)}-${title(var.env)}"
  account_id           = data.aws_caller_identity.current.account_id
  region               = data.aws_region_current_name
  region_account_id    = "${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}"
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

module "s3_bucket_layer" {
  source = "../tf-modules/s3"

  project = var.project
  env     = var.env

  bucket_name               = "layer-artifacts"
  bucket_versioning_enabled = "Disabled"
}