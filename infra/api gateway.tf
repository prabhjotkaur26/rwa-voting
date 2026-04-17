resource "aws_apigatewayv2_api" "api" {
  name          = "rwa-api"
  protocol_type = "HTTP"
}

# -----------------------------
# STAGE
# -----------------------------
resource "aws_apigatewayv2_stage" "stage" {
  api_id      = aws_apigatewayv2_api.api.id
  name        = "$default"
  auto_deploy = true
}

# -----------------------------
# INTEGRATIONS
# -----------------------------
resource "aws_apigatewayv2_integration" "auth" {
  api_id           = aws_apigatewayv2_api.api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.auth.invoke_arn
}

resource "aws_apigatewayv2_integration" "verify" {
  api_id           = aws_apigatewayv2_api.api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.verify.invoke_arn
}

resource "aws_apigatewayv2_integration" "vote" {
  api_id           = aws_apigatewayv2_api.api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.vote.invoke_arn
}

resource "aws_apigatewayv2_integration" "results" {
  api_id           = aws_apigatewayv2_api.api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.results.invoke_arn
}

resource "aws_apigatewayv2_integration" "admin" {
  api_id           = aws_apigatewayv2_api.api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.admin.invoke_arn
}

resource "aws_apigatewayv2_integration" "export" {
  api_id           = aws_apigatewayv2_api.api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.export.invoke_arn
}
resource "aws_apigatewayv2_integration" "download" {
  api_id           = aws_apigatewayv2_api.api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.download.invoke_arn
}

# -----------------------------
# ROUTES
# -----------------------------
resource "aws_apigatewayv2_route" "auth" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "POST /auth"
  target    = "integrations/${aws_apigatewayv2_integration.auth.id}"
}

resource "aws_apigatewayv2_route" "verify" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "POST /verify"
  target    = "integrations/${aws_apigatewayv2_integration.verify.id}"
}

resource "aws_apigatewayv2_route" "vote" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "POST /vote"
  target    = "integrations/${aws_apigatewayv2_integration.vote.id}"
}

resource "aws_apigatewayv2_route" "results" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "POST /results"
  target    = "integrations/${aws_apigatewayv2_integration.results.id}"
}

resource "aws_apigatewayv2_route" "admin" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "POST /admin"
  target    = "integrations/${aws_apigatewayv2_integration.admin.id}"
}

resource "aws_apigatewayv2_route" "export" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "POST /export"
  target    = "integrations/${aws_apigatewayv2_integration.export.id}"
}
resource "aws_apigatewayv2_route" "download" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "GET /download"
  target    = "integrations/${aws_apigatewayv2_integration.download.id}"
}
resource "aws_apigatewayv2_route" "get_results" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "GET /results"

  target = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}
# -----------------------------
# PERMISSIONS (VERY IMPORTANT)
# -----------------------------
resource "aws_lambda_permission" "auth" {
  statement_id  = "AllowAPIGatewayAuth"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.auth.function_name
  principal     = "apigateway.amazonaws.com"
}

resource "aws_lambda_permission" "verify" {
  statement_id  = "AllowAPIGatewayVerify"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.verify.function_name
  principal     = "apigateway.amazonaws.com"
}

resource "aws_lambda_permission" "vote" {
  statement_id  = "AllowAPIGatewayVote"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.vote.function_name
  principal     = "apigateway.amazonaws.com"
}

resource "aws_lambda_permission" "results" {
  statement_id  = "AllowAPIGatewayResults"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.results.function_name
  principal     = "apigateway.amazonaws.com"
}

resource "aws_lambda_permission" "admin" {
  statement_id  = "AllowAPIGatewayAdmin"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.admin.function_name
  principal     = "apigateway.amazonaws.com"
}
resource "aws_lambda_permission" "download" {
  statement_id  = "AllowAPIGatewayDownload"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.download.function_name
  principal     = "apigateway.amazonaws.com"
}

resource "aws_lambda_permission" "export" {
  statement_id  = "AllowAPIGatewayExport"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.export.function_name
  principal     = "apigateway.amazonaws.com"
}
