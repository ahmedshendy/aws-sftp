resource "aws_secretsmanager_secret" "secret" {
  name = "SFTP/${var.sftp-username}"
}

resource "aws_iam_role" "iam-role-sftp-secret" {
  name = "transfer-server-secrets-${var.sftp-username}-iam-role"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
        "Effect": "Allow",
        "Principal": {
            "Service": "transfer.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "iam-role-sftp-secrets-policy" {
  name = "transfer-server-secrets-${var.sftp-username}-iam-policy"
  role = "${aws_iam_role.iam-role-sftp-secret.id}"

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": ["s3:ListBucket"],
        "Resource": ["arn:aws:s3:::${var.sftp_bucket_name}"]
      },
      {
        "Effect": "Allow",
        "Action": [
          "s3:PutObject",
          "s3:GetObject"
        ],
        "Resource": ["arn:aws:s3:::${var.sftp_bucket_name}/${var.sftp-username}/*"]
      }
    ]
  }
POLICY
}

resource "aws_secretsmanager_secret_version" "secret_version" {
  secret_id     = "${aws_secretsmanager_secret.secret.id}"
  secret_string = <<EOF
  {
    "Password" : "${var.sftp-password}", 
    "Role" : "${aws_iam_role.iam-role-sftp-secret.arn}",
    "HomeDirectory" : "/${var.sftp_bucket_name}/${var.sftp-username}"
  }
  EOF
}

resource "aws_s3_bucket_object" "userFolder" {
    bucket = "${var.sftp_bucket_id}"
    acl    = "private"
    key    = "${var.sftp-username}/"
}