########################################
# HTTP API
########################################
resource "aws_apigatewayv2_api" "api" {
  name          = "rwa-api"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["GET", "POST", "OPTIONS"]
    allow_headers = ["Content-Type", "Authorization"]
    max_age       = 3600
  }
}

########################################
# DEFAULT STAGE
########################################
resource "aws_apigatewayv2_stage" "stage" {
  api_id      = aws_apigatewayv2_api.api.id
  name        = "$default"
  auto_deploy = true
}

########################################
# LAMBDAS MAP
########################################
locals {
  lambdas = {
    auth     = aws_lambda_function.auth
    verify   = aws_lambda_function.verify
    vote     = aws_lambda_function.vote
    results  = aws_lambda_function.results
    admin    = aws_lambda_function.admin
    export   = aws_lambda_function.export
    download = aws_lambda_function.download
  }
}

########################################
# API INTEGRATIONS
########################################
resource "aws_apigatewayv2_integration" "lambda" {
  for_each = local.lambdas

  api_id                 = aws_apigatewayv2_api.api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = each.value.invoke_arn
  payload_format_version = "2.0"

  depends_on = [
    aws_lambda_function.auth,
    aws_lambda_function.verify,
    aws_lambda_function.vote,
    aws_lambda_function.results,
    aws_lambda_function.admin,
    aws_lambda_function.export,
    aws_lambda_function.download
  ]
}

########################################
# ROUTES
########################################
resource "aws_apigatewayv2_route" "routes" {
  for_each = local.lambdas

  api_id    = aws_apigatewayv2_api.api.id
  route_key = "POST /${each.key}"

  target = "integrations/${aws_apigatewayv2_integration.lambda[each.key].id}"
}

########################################
# LAMBDA PERMISSIONS FOR API GATEWAY
########################################
resource "aws_lambda_permission" "apigw" {
  for_each = local.lambdas

  statement_id  = "AllowAPIGateway-${each.key}"
  action        = "lambda:InvokeFunction"
  function_name = each.value.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.api.execution_arn}/*/*"
}
