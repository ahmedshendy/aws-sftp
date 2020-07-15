#Creating S3 Bucket with versioning enable
resource "aws_s3_bucket" "bucket" {

  bucket = "${var.bucket-name}"

  acl    = "${var.acl}"


  versioning {

    enabled = "${var.versioning-enable}"

  }



  lifecycle {

    prevent_destroy = false

  }



  tags = {

    Name = "${var.bucket-name}"

  }

}