#S3 VARIABLES

variable "sftp-username" {
  default = ""
}

variable "sftp-password" {
  default = ""
}

variable "sftp_bucket_name" {
  description = "The name of the sftp s3 bucket"
  default = ""
}

variable "sftp_bucket_id" {
  description = "The id of the sftp s3 bucket"
  default = ""
}