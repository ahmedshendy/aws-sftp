
variable "region" {
  description = "Region in which to deploy all resources"
  default = "us-east-2"
}

####################
# Tags
####################
variable "project" {
  description = "Project name for tags and resource naming"
  default = "sftp"
}

variable "owner" {
  description = "Contact person responsible for the resource"
  default = "sddx"
}

variable "costcenter" {
  description = "Cost Center tag"
  default = "sftp"
}

variable "service" {
  description = "Service name"
  default = "sftp"
}
####################
# SFTP
####################
variable "sftp_bucket_name" {
  description = "The name of the sftp s3 bucket"
  default = "shendy-sftp"
}
variable "handled_bucket_name" {
  description = "The name of the sftp s3 bucket"
  default = "shendy-handled"
}

####################
# Lambda
####################
variable "lambda_runtime" {
  description = "Lambda Function runtime"
  default = "python3.7"
}

variable "lambda_repo_bucket" {
  description = "Lambda Repo S3"
  default = "3ddx-lamdda-pkg"
}
variable "lambda_handler" {
  description = "Lambda Function Handler"
  default = "index.lambda_handler"
}

####################
# Lambda sftpCustomAuthorizer
####################
variable "lambda_auth_zip_path" {
  description = "Lambda Function Zipfile local path for S3 Upload"
  default = "sftpCustomAuthorizer.zip"
}

variable "lambda_auth_function_name" {
  description = "Lambda Function Name"
  default     = "SFTPCustomAuthorizer"
}

variable "lambda_auth_memory" {
  description = "Lambda memory size, 128 MB to 3,008 MB, in 64 MB increments"
  default = "128"
}


####################
# Lambda sftpFileHandler
####################
variable "lambda_handler_zip_path" {
  description = "Lambda Function Zipfile local path for S3 Upload"
  default = "sftpFileHandler.zip"
}

variable "lambda_handler_function_name" {
  description = "Lambda Function Name"
  default     = "sftpFileHandler"
}

variable "lambda_handler_memory" {
  description = "Lambda memory size, 128 MB to 3,008 MB, in 64 MB increments"
  default = "256"
}
####################
# API Gateway
####################

variable "account_id" {
  description = "Account ID needed to construct ARN to allow API Gateway to invoke lambda function"
  default = "919139699099"
}

######