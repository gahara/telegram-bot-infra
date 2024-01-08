variable "requirements_name" {
  description = "Path to requirements.txt"
  type        = string
  default     = "requirements.txt"
}

variable "venv_layer" {
  description = "Name of layer containing venv"
  type        = string
  default     = "venv_layer"
}

variable "s3_venv_layer_key" {
  description = "Key for venv layer"
  type        = string
  default     = "karuguchi_bot_venv"
}

variable "runtime_python_versions" {
  description = "Compatible python versions"
  type        = list(string)
  default     = ["python3.9"]
}

variable "runtime_python_main_version" {
  description = "Main python version"
  type        = string
  default     = "python3.9"
}

variable "region" {
  description = "Region"
  type        = string
  default     = "us-east-1"
}

variable "TELEGRAM_TOKEN" {
  description = "Secret telegram token"
  type        = string
}

variable "LAMBDA_BUCKET_NAME" {
  description = "S3 bucket name to store stuff"
  type        = string
}
variable "lambda_function_code_zip" {
  description = "Code for lambda function, zipped"
  type        = string
  default     = "lambda_function_code.zip"
}