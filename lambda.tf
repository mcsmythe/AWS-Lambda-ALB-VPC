resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

data "aws_ecr_repository" "service" {
  name = "lambda-container"
}

resource "aws_lambda_function" "test_lambda" {
  
  function_name = "lambda_container"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "app.handler"
  runtime       = "python3.8"
  image_uri     = "${data.aws_ecr_repository.service.repository_url}:1"
  #image_uri     = "${var.ecr_repository_url}:${var.docker_image_tag}"
  package_type  = "Image"
}

resource "aws_apigatewayv2_api" "lambda_api"{
    name = "v2-http-api"
    protocol_type = "HTTP"

}

resource "aws_apigatewayv2_stage" "lambda_stage" {
    api_id = aws_apigatewayv2_api.lambda_api.id
    name = "$default"
    auto_deploy = true   
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
    api_id = aws_apigatewayv2_api.lambda_api.id
    integration_type = "AWS_PROXY"
    integration_method = "POST"
    integration_uri = aws_lambda_function.test_lambda.invoke_arn
    passthrough_behavior = "WHEN_NO_MATCH" 

}

resource "aws_apigatewayv2_route" "lambda_route" {
    api_id = aws_apigatewayv2_api.lambda_api.id
    route_key = "GET /{proxy+}"
    target = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_lambda_permission" "api_gw" {
    statement_id = "AllowExecutionFromAPIGateway"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.test_lambda.arn
    principal = "apigateway.amazonaws.com"
    source_arn = "${aws_apigatewayv2_api.lambda_api.execution_arn}/*/*/*"
}
