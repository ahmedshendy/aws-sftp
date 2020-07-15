provider "aws" {
  region = "${var.region}"
  access_key = "xxxxxxxxxx"
  secret_key = "xxxxxxxxxxxxxxxxxxxxxxxx"
}

data "aws_caller_identity" "current" {}

####################
# SFTP S3 Bucket Name
####################
module "s3" {
  source = "../modules/aws-s3"
  bucket-name = "${var.sftp_bucket_name}"
  acl = "private"
  versioning-enable = "true"
}

####################
# Handled S3 Bucket Name
####################
module "s3_handled" {
  source = "../modules/aws-s3"
  bucket-name = "${var.handled_bucket_name}"
  acl = "private"
  versioning-enable = "true"
}

####################
# Lambda sftpCustomAuthorizer
####################
module "lambda" {
  source        = "../modules/aws-lambda"
  s3_bucket     = "${var.lambda_repo_bucket}"
  s3_key        = "${var.lambda_auth_zip_path}"
  function_name = "${var.project}-${var.lambda_auth_function_name}"
  handler       = "${var.lambda_handler}"
  runtime       = "${var.lambda_runtime}"
  memory        = "${var.lambda_auth_memory}"
  secrets_manager_region  = "${var.region}"
}


####################
# Lambda sftpFileHandler
####################
module "lambda_file_handler" {
  source        = "../modules/aws-lambda-handler"
  s3_bucket     = "${var.lambda_repo_bucket}"
  s3_key        = "${var.lambda_handler_zip_path}"
  function_name = "${var.project}-${var.lambda_handler_function_name}"
  handler       = "${var.lambda_handler}"
  runtime       = "${var.lambda_runtime}"
  memory        = "${var.lambda_handler_memory}"
  target_bucket  = "${var.handled_bucket_name}"
  trigger_bucket_arn = "${module.s3.s3-bucket-arn}"
  trigger_bucket_id = "${module.s3.s3-bucket-id}"
}

####################
# API
####################
module "api" {
  name       = "${module.lambda.name}"
  source     = "../modules/aws-api"
  method     = "GET"
  lambda     = "${module.lambda.name}"
  lambda_arn = "${module.lambda.arn}"
  region     = "${var.region}"
  account_id = "${var.account_id}"
  stage_name = "prod"
}

####################
# SFTP
####################
module "sftp" {
  source     = "../modules/aws-sftp"
  aws-transfer-server-name = "shendy-sftp"
  api-gateway-url       = "${module.api.api_url}"
}

####################
# Secret Manager
####################
module "secretUser1" {
  source     = "../modules/aws-secret-manager"
  sftp-username = "user1"
  sftp-password = "password1"
  sftp_bucket_name       = "${module.s3.s3-bucket-id}"
  sftp_bucket_id       = "${module.s3.s3-bucket-id}"
}
module "secretUser2" {
  source     = "../modules/aws-secret-manager"
  sftp-username = "user2"
  sftp-password = "password2"
  sftp_bucket_name       = "${module.s3.s3-bucket-id}"
  sftp_bucket_id       = "${module.s3.s3-bucket-id}"
}