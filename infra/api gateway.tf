resource "aws_apigatewayv2_api" "api" {
  name          = "rwa-api"
  protocol_type = "HTTP"

  # ✅ CORS FIX (MOST IMPORTANT)
  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["GET", "POST", "OPTIONS"]
    allow_headers = ["Content-Type", "Authorization"]
    expose_headers = ["Authorization"]
    max_age = 3600
  }
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
# ROUTES (OPTIMIZED)
# -----------------------------

# AUTH
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

# VOTING
resource "aws_apigatewayv2_route" "vote" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "POST /vote"
  target    = "integrations/${aws_apigatewayv2_integration.vote.id}"
}

# RESULTS
resource "aws_apigatewayv2_route" "get_results" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "GET /results"
  target    = "integrations/${aws_apigatewayv2_integration.results.id}"
}

# ADMIN
resource "aws_apigatewayv2_route" "admin" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "GET /admin"
  target    = "integrations/${aws_apigatewayv2_integration.admin.id}"
}

# EXPORT
resource "aws_apigatewayv2_route" "export" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "GET /export"
  target    = "integrations/${aws_apigatewayv2_integration.export.id}"
}

# DOWNLOAD
resource "aws_apigatewayv2_route" "download" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "GET /download"
  target    = "integrations/${aws_apigatewayv2_integration.download.id}"
}

# -----------------------------
# PERMISSIONS (FIXED)
# -----------------------------
resource "aws_lambda_permission" "all" {
  for_each = {
    auth     = aws_lambda_function.auth.function_name
    verify   = aws_lambda_function.verify.function_name
    vote     = aws_lambda_function.vote.function_name
    results  = aws_lambda_function.results.function_name
    admin    = aws_lambda_function.admin.function_name
    export   = aws_lambda_function.export.function_name
    download = aws_lambda_function.download.function_name
  }

  statement_id  = "AllowAPIGateway-${each.key}"
  action        = "lambda:InvokeFunction"
  function_name = each.value
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.api.execution_arn}/*/*"
}
