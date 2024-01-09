# Модуль чтобы сделать С3 переиспользуемым
resource "aws_s3_bucket" "main" {
  bucket              = "${local.resource_name_prefix}-${var.bucket_name}"
  object_lock_enabled = false
  tags                = merge({
    "Name" = "${local.resource_name_prefix}-${var.bucket_name}"
  })
}

resource "aws_s3_bucket_public_access_block" "bucket_block_public_access" {
  bucket                  = aws_s3_bucket.main.id # указывает на сущность вверху
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "bucket_versioning" {
  bucket = aws_s3_bucket.main.id # указывает на сущность вверху

  versioning_configuration {
    status = var.bucket_versioning_enabled
  }
}