
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
# API INTEGRATIONS (LAMBDA MAP)
########################################
resource "aws_apigatewayv2_integration" "lambda" {
  for_each = {
    "send-otp"   = aws_lambda_function.auth
    "verify-otp" = aws_lambda_function.verify
    "vote"       = aws_lambda_function.vote
    "results"    = aws_lambda_function.results
    "admin"      = aws_lambda_function.admin
    "export"     = aws_lambda_function.export
    "download"   = aws_lambda_function.download
  }

  api_id                 = aws_apigatewayv2_api.api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = each.value.invoke_arn
  payload_format_version = "2.0"
}

########################################
# ROUTES (IMPORTANT FIX)
########################################
resource "aws_apigatewayv2_route" "routes" {
  for_each = aws_apigatewayv2_integration.lambda

  api_id    = aws_apigatewayv2_api.api.id
  route_key = "POST /${each.key}"

  target = "integrations/${each.value.id}"
}

########################################
# LAMBDA PERMISSIONS
########################################
resource "aws_lambda_permission" "apigw" {
  for_each = {
    "send-otp"   = aws_lambda_function.auth
    "verify-otp" = aws_lambda_function.verify
    "vote"       = aws_lambda_function.vote
    "results"    = aws_lambda_function.results
    "admin"      = aws_lambda_function.admin
    "export"     = aws_lambda_function.export
    "download"   = aws_lambda_function.download
  }

  statement_id  = "AllowAPIGateway-${each.key}"
  action        = "lambda:InvokeFunction"
  function_name = each.value.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.api.execution_arn}/*/*"
}
