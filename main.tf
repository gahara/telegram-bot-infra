terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.26.0"
    }
  }
  required_version = ">= 1.2.0"
  backend "s3" {
  }
}

provider "aws" {
  region = var.region
}

resource "aws_iam_role" "test_bot_lambda_role" {
  name               = "test_Bot_Lambda_Function_Role"
  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "lambda.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}
data "aws_iam_policy_document" "test_bot_lambda_policy_doc" {
  statement {

    effect = "Allow"

    actions = [
      "ssm:Get*",
    ]

    resources = [
      "*"
    ]
  }
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:*:*:*"
    ]
    effect = "Allow"
  }
  statement {
    sid = "VolumeEncryption"
    actions = ["kms:Encrypt",
      "kms:Decrypt",
    "kms:DescribeKey"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "iam_policy_for_test_bot_lambda" {
  name        = "aws_iam_policy_for_test_bot_lambda"
  path        = "/"
  description = "AWS IAM Policy for managing aws lambda role"
  policy      = data.aws_iam_policy_document.test_bot_lambda_policy_doc.json
}

resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role" {
  role       = aws_iam_role.test_bot_lambda_role.name
  policy_arn = aws_iam_policy.iam_policy_for_test_bot_lambda.arn
}

data "archive_file" "zip_lambda_code" {
  type        = "zip"
  source_dir  = "${path.module}/func/"
  output_path = "${path.module}/${var.lambda_function_code_zip}"
}

resource "null_resource" "venv" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = "which python && python --version && pip install -r requirements.txt -t layer/python"
  }
}

data "archive_file" "zip_layer_content" {
  type        = "zip"
  source_dir  = "${path.module}/layer"
  output_path = "${path.module}/${var.venv_layer}.zip"
  depends_on  = [null_resource.venv]
}

resource "aws_s3_object" "test_bot_venv_zip" {
  bucket     = var.LAMBDA_BUCKET_NAME
  key        = "lambda_layers/${var.venv_layer}/${var.s3_venv_layer_key}.zip"
  source     = "${path.module}/${var.venv_layer}.zip"
  etag       = filemd5("${path.module}/${var.requirements_name}")
  depends_on = [data.archive_file.zip_layer_content]
}

resource "aws_lambda_layer_version" "test_bot_venv" {
  layer_name          = "test_bot_layer"
  s3_bucket           = var.LAMBDA_BUCKET_NAME
  s3_key              = aws_s3_object.test_bot_venv_zip.key
  compatible_runtimes = var.runtime_python_versions
  source_code_hash    = filemd5("${path.module}/${var.requirements_name}")
  depends_on          = [aws_s3_object.test_bot_venv_zip]
}

resource "aws_ssm_parameter" "telegram_token" {
  name      = "telegram_token"
  type      = "SecureString"
  value     = var.TELEGRAM_TOKEN
  overwrite = true
}

resource "aws_lambda_function" "test_bot_lambda_func" {
  filename         = "${path.module}/${var.lambda_function_code_zip}"
  function_name    = "test_bot_func"
  role             = aws_iam_role.test_bot_lambda_role.arn
  handler          = "test_bot.lambda_handler"
  runtime          = var.runtime_python_main_version
  source_code_hash = data.archive_file.zip_lambda_code.output_base64sha256
  depends_on       = [aws_iam_role_policy_attachment.attach_iam_policy_to_iam_role]
  layers           = [aws_lambda_layer_version.test_bot_venv.arn]
  timeout          = 120
}

resource "aws_lambda_function_url" "webhook_url" {
  function_name      = aws_lambda_function.test_bot_lambda_func.arn
  authorization_type = "NONE"
}
