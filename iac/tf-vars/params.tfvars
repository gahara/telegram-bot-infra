resource_region = "us-east-1"
region          = "us-east-1" #Asia Pacific North East 1 - Tokyo

project = "testBot"
env     = "prod"

default_tags = {
  "with-love" = "from @gahara"
}


policy_name = "aws_iam_test_bot_policy"

role_name = "aws_iam_test_bot_role"

api_resources = {
  "ai_bot" = {
    handler      = "test_bot.lambda_handler"
    runtime      = "python3.11"
    memory_size  = "512"
    package_type = "Zip"
    timeout      = "120"

    environment_variables = {
      LOG_LEVEL = "INFO"
    }

    layer_create = true

    ssm_params = {
      "telegram_token" = {
        type = "SecureString"
        # value extracted from env parameter like:
        # TF_VARS_KARUGUCHI_PROD_TELEGRAM_TOKEN
      }
    }
  }
}