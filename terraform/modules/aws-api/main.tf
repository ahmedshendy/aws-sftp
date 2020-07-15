# API Gateway
resource "aws_api_gateway_rest_api" "api" {
  name = "${var.name}"
}

resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  stage_name  = "${var.stage_name}"
  depends_on  = ["aws_api_gateway_integration.request_method_integration", "aws_api_gateway_integration_response.response_method_integration"]
}

resource "aws_api_gateway_model" "GetUserConfigResponseModel" {
  rest_api_id  = "${aws_api_gateway_rest_api.api.id}"
  name         = "UserConfigResponseModel"
  description  = "API response for GetUserConfig"
  content_type = "application/json"

  schema = <<EOF
{"$schema":"http://json-schema.org/draft-04/schema#","title":"UserUserConfig","type":"object","properties":{"Role":{"type":"string"},"Policy":{"type":"string"},"HomeDirectory":{"type":"string"},"PublicKeys":{"type":"array","items":{"type":"string"}}}}
EOF
}

resource "aws_api_gateway_resource" "ServersResource" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  parent_id   = "${aws_api_gateway_rest_api.api.root_resource_id}"
  path_part   = "servers"
}

resource "aws_api_gateway_resource" "ServerIdResource" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  parent_id   = "${aws_api_gateway_resource.ServersResource.id}"
  path_part   = "{serverId}"
}
resource "aws_api_gateway_resource" "UsersResource" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  parent_id   = "${aws_api_gateway_resource.ServerIdResource.id}"
  path_part   = "users"
}
resource "aws_api_gateway_resource" "UserNameResource" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  parent_id   = "${aws_api_gateway_resource.UsersResource.id}"
  path_part   = "{username}"
}
resource "aws_api_gateway_resource" "GetUserConfigResource" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  parent_id   = "${aws_api_gateway_resource.UserNameResource.id}"
  path_part   = "config"
}
resource "aws_api_gateway_method" "request_method" {
  rest_api_id   = "${aws_api_gateway_rest_api.api.id}"
  resource_id   = "${aws_api_gateway_resource.GetUserConfigResource.id}"
  http_method   = "${var.method}"
  authorization = "AWS_IAM"
  request_parameters = {"method.request.header.Password" = true}
  depends_on =  ["aws_api_gateway_model.GetUserConfigResponseModel"]
}

resource "aws_api_gateway_integration" "request_method_integration" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  resource_id = "${aws_api_gateway_resource.GetUserConfigResource.id}"
  http_method = "${aws_api_gateway_method.request_method.http_method}"
  type        = "AWS"
  uri         = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${var.lambda_arn}/invocations"

  # AWS lambdas can only be invoked with the POST method
  integration_http_method = "POST"
  request_templates = {
    "application/json" = <<EOF
            {
              "username": "$input.params('username')",
              "password": "$util.escapeJavaScript($input.params('Password')).replaceAll("\\'","'")",
              "serverId": "$input.params('serverId')"
            }
EOF
  }
}

# lambda => GET response
resource "aws_api_gateway_method_response" "response_method" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  resource_id = "${aws_api_gateway_resource.GetUserConfigResource.id}"
  http_method = "${aws_api_gateway_integration.request_method_integration.http_method}"
  status_code = "200"

  response_models = {
    "application/json" = "UserConfigResponseModel"
  }
}

resource "aws_api_gateway_integration_response" "response_method_integration" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  resource_id = "${aws_api_gateway_resource.GetUserConfigResource.id}"
  http_method = "${aws_api_gateway_method_response.response_method.http_method}"
  status_code = "${aws_api_gateway_method_response.response_method.status_code}"
}

resource "aws_lambda_permission" "allow_api_gateway" {
  function_name = "${var.lambda_arn}"
  statement_id  = "AllowExecutionFromApiGateway"
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.region}:${var.account_id}:${aws_api_gateway_rest_api.api.id}/*/${var.method}${aws_api_gateway_resource.GetUserConfigResource.path}"
  depends_on    = ["aws_api_gateway_rest_api.api", "aws_api_gateway_resource.GetUserConfigResource"]
}

resource "aws_api_gateway_account" "api_account" {
  cloudwatch_role_arn = "${aws_iam_role.api_log_role.arn}"
}
resource "aws_iam_role" "api_log_role" {
  name = "${var.name}-log-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "logs" {
  name = "${aws_iam_role.api_log_role.name}-logs"
  role = "${aws_iam_role.api_log_role.id}"

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