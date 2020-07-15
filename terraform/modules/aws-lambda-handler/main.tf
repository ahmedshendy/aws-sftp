resource "aws_lambda_function" "lambda" {
  s3_bucket        = "${var.s3_bucket}"
  s3_key           = "${var.s3_key}"
  function_name    = "${var.function_name}"
  role             = "${aws_iam_role.role.arn}"
  handler          = "${var.handler}"
  runtime          = "${var.runtime}"
  memory_size      = "${var.memory}"


  environment {
    variables = {
      TargetBucket = "${var.target_bucket}"
    }
  }
}


resource "aws_iam_role" "role" {
  name = "${var.function_name}-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "handler_logs" {
  name = "${aws_iam_role.role.name}-logs"
  role = "${aws_iam_role.role.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:DescribeLogGroups",
                "logs:DescribeLogStreams",
                "logs:PutLogEvents",
                "logs:GetLogEvents",
                "logs:FilterLogEvents"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.lambda.arn}"
  principal     = "s3.amazonaws.com"
  source_arn    = "${var.trigger_bucket_arn}"
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = "${var.trigger_bucket_id}"

  lambda_function {
    lambda_function_arn = "${aws_lambda_function.lambda.arn}"
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".zip"
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}