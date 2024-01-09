# creates zip file from requirements.txt. Triggered by updating the file
resource "null_resource" "lambda_layer" {
  count = var.layer_create ? 1 : 0

  triggers = {
    # чтобы можно было requirements.txt не в корне хранить
    requirements = filesha1("${local.lambda_src_dir}/requirements.txt")
  }

  provisioner "local-exec" {
    command = <<EOT
      rm -rf ${local.tmp_layer_path}/python
      mkdir -p ${local.tmp_layer_path}/python

      which python
      python --version

      cd ${local.tmp_layer_path}/python
      pip install -r ../"${local.lambda_src_dir}/requirements.txt" --only-binary=:all: --python-version 3.11 --platform manylinux2014_x86_64 -t python > /dev/null

      zip -r ${local.layer_zip_file_name} python > /dev/null

      # https://amacal.medium.com/filebase64sha256-and-terraform-cabfd385c49e
      aws s3 cp --no-progress --metadata sha256=$(cat ${local.layer_zip_file_name} | openssl dgst -binary -sha256 | openssl base64) ${local.layer_zip_file_name} s3://${var.layer_bucket_name}/lambda_layers/${local.name}/${local.layer_zip_file_name}
    EOT
  }
}

data "aws_s3_object" "layer_zip" {
  count      = var.layer_create ? 1 : 0
  bucket     = var.layer_bucket_name
  key        = "lambda_layers/${local.name}/${local.layer_zip_file_name}"
  depends_on = [null_resource.lambda_layer]
}

# create layer for s3
resource "aws_lambda_layer_version" "lambda_layer" {
  count               = var.layer_create?1 : 0
  s3_bucket           = var.layer_bucket_name
  s3_key              = "lambda_layers/${local.name}/${local.layer_zip_file_name}"
  layer_name          = local.name
  compatible_runtimes = [var.runtime]
  skip_destroy        = false
  source_code_hash    = data.aws_s3_object.layer_zip[0].metadata["sha256"]
  depends_on          = [null_resource.lambda_layer]
}

resource "aws_iam_role" "tg_bot_lambda_role" {
  name               = "tg_Bot_Lambda_Function_Role"
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
data "aws_iam_policy_document" "tg_bot_lambda_policy_doc" {
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
    sid     = "VolumeEncryption"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:DescribeKey"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "iam_policy_for_tg_bot_lambda" {
  name        = "aws_iam_policy_for_tg_bot_lambda"
  path        = "/"
  description = "AWS IAM Policy for managing aws lambda role"
  policy      = data.aws_iam_policy_document.tg_bot_lambda_policy_doc.json
}

resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role" {
  role       = aws_iam_role.tg_bot_lambda_role.name
  policy_arn = aws_iam_policy.iam_policy_for_tg_bot_lambda.arn
}

data "archive_file" "lambda" {
  type        = "zip"
  source_dir  = local.lambda_src_dir
  output_path = local.lambda_zip_file_name
}

resource "aws_lambda_function" "webhook_url" {
  filename      = local.lambda_zip_file_name
  function_name = local.name
  role          = aws_iam_role.tg_bot_lambda_role.arn
  handler       = var.handler

  memory_size      = var.memory_size
  package_type     = var.package_type
  source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = var.runtime
  timeout = var.timeout
  layers  = concat(
    var.layer_create == true ? [aws_lambda_layer_version.lambda_layer[0].arn] : [var.layer_powertools]
  )

  architectures = ["x86_64"]

  environment {
    variables = merge({
      ENVIRONMENT = lower(var.env)
    }, var.environment_variables)
  }

  tags = merge({
    "Name" = local.name
  })
}

resource "aws_lambda_function_url" "webhook_url" {
  function_name      = aws_lambda_function.webhook_url.function_name
  authorization_type = "NONE"

  depends_on = [aws_lambda_function.webhook_url]
}