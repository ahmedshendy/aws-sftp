resource "aws_transfer_server" "sftp" {
  identity_provider_type = "API_GATEWAY"
  url = "${var.api-gateway-url}"
  logging_role           = "${aws_iam_role.iam-role-sftp.arn}"
  invocation_role = "${aws_iam_role.iam-role-sftp-api-invocation.arn}"

  tags = {
    NAME     = "${var.aws-transfer-server-name}"
  }
}

resource "aws_iam_role" "iam-role-sftp" {
  name = "transfer-server-logging-iam-role"

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

resource "aws_iam_role_policy" "iam-role-sftp-policy" {
  name = "transfer-server-iam-policy"
  role = "${aws_iam_role.iam-role-sftp.id}"

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
        "Sid": "AllowFullAccesstoCloudWatchLogs",
        "Effect": "Allow",
        "Action": [
            "logs:*"
        ],
        "Resource": "*"
        }
    ]
}
POLICY
}

resource "aws_iam_role" "iam-role-sftp-api-invocation" {
  name = "transfer-server-api-invocation-iam-role"

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

resource "aws_iam_role_policy" "TransferCanInvokeThisApi-policy" {
  name = "TransferCanInvokeThisApi"
  role = "${aws_iam_role.iam-role-sftp-api-invocation.id}"

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
        "Effect": "Allow",
        "Action": [
                "execute-api:Invoke"
            ],
        "Resource": "arn:aws:execute-api:*"
        }
    ]
}
POLICY
}
resource "aws_iam_role_policy" "TransferCanReadThisApi-policy" {
  name = "TransferCanReadThisApi"
  role = "${aws_iam_role.iam-role-sftp-api-invocation.id}"

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
        "Effect": "Allow",
        "Action": [
                "apigateway:GET"
            ],
        "Resource": "*"
        }
    ]
}
POLICY
}