output "bucket_name" {
  value = zipmap([var.bucket_name], [aws_s3_bucket.main.bucket])
}