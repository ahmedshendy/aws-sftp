variable "function_name" {
  description = "The name of the lambda function"
}

variable "runtime" {
  description = "The runtime of the lambda to create"
}

variable "s3_bucket" {
  description = "s3 bucket repo"
}

variable "s3_key" {
  description = "The filename of the lambda zip in s3 bucket"
}

variable "handler" {
  description = "The handler name of the lambda function"
}

variable "memory" {
  description = "The memory size of the lambda function"
}

variable "target_bucket" {
  description = "target bucket for the handled files"
}

variable "trigger_bucket_arn" {
  description = "the arn of the source bucket"
}
variable "trigger_bucket_id" {
  description = "the id of the source bucket"
}

