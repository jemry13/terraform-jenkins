# Variables
variable "region" {
  type = "string",
  default = "ap-southeast-2"
}


provider "aws" {
  region = "${var.region}"
}

# Lambda
resource "aws_iam_role" "lambda" {
  name = "alejo_greeter_terraform_role"
  assume_role_policy = "${data.aws_iam_policy_document.lambda-assume-role.json}"
}
 
data "aws_iam_policy_document" "lambda-assume-role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    principals {
      type = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }
  }
}
data "archive_file" "lambda" { 
  type = "zip"
  source_file = "lambda.js"
  output_path = "lambda.zip"
}

resource "aws_lambda_function" "greeter-lambda" {
  filename = "${data.archive_file.lambda.output_path}"
  function_name = "alejo_greeteer_terraform_lambda"
  role = "${aws_iam_role.lambda.arn}"
  handler = "lambda.handler"
  runtime = "nodejs8.10"
  source_code_hash = "${base64sha256(file(data.archive_file.lambda.output_path))}"
}

# Cloudwatch
# resource "aws_iam_role_policy" "lambda-cloudwatch-log-group" {
#   name = "alejo_greeter_cloudwatch_log_group"
#   role = "${aws_iam_role.lambda.name}"
#   policy = "${data.aws_iam_policy_document.cloudwatch-log-group-lambda.json}"
# }
resource "aws_iam_role_policy_attachment" "LambdaCloudWatchAccess_attachment" {
  role       = "${aws_iam_role.lambda.name}"
  policy_arn = "${aws_iam_policy.LambdaCloudWatchAccess.arn}"
}
 
resource "aws_iam_policy" "LambdaCloudWatchAccess" {
  name = "LambdaCloudWatchAccess"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

# API Gateway
resource "aws_api_gateway_rest_api" "api" {
  name = "alejo_greeter_terraform_api_gateway"
}

resource "aws_api_gateway_resource" "api-resource" {
  path_part = "greetings"
  parent_id = "${aws_api_gateway_rest_api.api.root_resource_id}"
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
}

resource "aws_api_gateway_method" "method" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  resource_id = "${aws_api_gateway_resource.api-resource.id}"
  http_method = "GET"
  authorization = "NONE"
}

# Integrate API Gateway with the lambda function
resource "aws_api_gateway_integration" "integration" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  resource_id = "${aws_api_gateway_resource.api-resource.id}"
  http_method = "${aws_api_gateway_method.method.http_method}"
  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri = "${aws_lambda_function.greeter-lambda.invoke_arn}"
}
 
resource "aws_lambda_permission" "greeter-permissions" {
  statement_id = "AllowExecutionFromAPIGateway"
  action = "lambda:InvokeFunction"
  principal = "apigateway.amazonaws.com"
  function_name = "${aws_lambda_function.greeter-lambda.arn}"
}

resource "aws_api_gateway_deployment" "alejo_greeter_terraform_api_deployment" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  stage_name = "test"
  depends_on = ["aws_api_gateway_integration.integration",
               "aws_lambda_permission.greeter-permissions"]
}