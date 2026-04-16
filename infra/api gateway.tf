# -------------------------------
# REST API
# -------------------------------
resource "aws_api_gateway_rest_api" "api" {
  name = "rwa-api"
}

# -------------------------------
# AUTH REQUEST OTP (/auth-request)
# -------------------------------
resource "aws_api_gateway_resource" "auth_request" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "auth-request"
}

resource "aws_api_gateway_method" "auth_request_post" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.auth_request.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "auth_request_lambda" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.auth_request.id
  http_method             = aws_api_gateway_method.auth_request_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.auth.invoke_arn
}

# -------------------------------
# AUTH VERIFY OTP (/auth-verify)
# -------------------------------
resource "aws_api_gateway_resource" "auth_verify" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "auth-verify"
}

resource "aws_api_gateway_method" "auth_verify_post" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.auth_verify.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "auth_verify_lambda" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.auth_verify.id
  http_method             = aws_api_gateway_method.auth_verify_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.verify.invoke_arn
}

# -------------------------------
# VOTE (/vote)
# -------------------------------
resource "aws_api_gateway_resource" "vote" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "vote"
}

resource "aws_api_gateway_method" "vote_post" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.vote.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "vote_lambda" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.vote.id
  http_method             = aws_api_gateway_method.vote_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.vote.invoke_arn
}

# -------------------------------
# ADMIN RESULTS (/admin-results)
# -------------------------------
resource "aws_api_gateway_resource" "admin_results" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "admin-results"
}

resource "aws_api_gateway_method" "admin_results_get" {
  rest_api_id      = aws_api_gateway_rest_api.api.id
  resource_id      = aws_api_gateway_resource.admin_results.id
  http_method      = "GET"
  authorization    = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_integration" "admin_results_lambda" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.admin_results.id
  http_method             = aws_api_gateway_method.admin_results_get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.admin.invoke_arn
}

# -------------------------------
# ADMIN EXPORT (/admin-export)
# -------------------------------
resource "aws_api_gateway_resource" "admin_export" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "admin-export"
}

resource "aws_api_gateway_method" "admin_export_get" {
  rest_api_id      = aws_api_gateway_rest_api.api.id
  resource_id      = aws_api_gateway_resource.admin_export.id
  http_method      = "GET"
  authorization    = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_integration" "admin_export_lambda" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.admin_export.id
  http_method             = aws_api_gateway_method.admin_export_get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.export.invoke_arn
}

# -------------------------------
# LAMBDA PERMISSIONS (SECURE)
# -------------------------------
resource "aws_lambda_permission" "auth_permission" {
  statement_id  = "AllowAuthInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.auth.function_name
  principal     = "apigateway.amazonaws.com"
}

resource "aws_lambda_permission" "verify_permission" {
  statement_id  = "AllowVerifyInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.verify.function_name
  principal     = "apigateway.amazonaws.com"
}

resource "aws_lambda_permission" "vote_permission" {
  statement_id  = "AllowVoteInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.vote.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}
resource "aws_lambda_permission" "admin_permission" {
  statement_id  = "AllowAdminInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.admin.function_name
  principal     = "apigateway.amazonaws.com"
}

resource "aws_lambda_permission" "export_permission" {
  statement_id  = "AllowExportInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.export.function_name
  principal     = "apigateway.amazonaws.com"
}

# -------------------------------
# DEPLOYMENT
# -------------------------------
resource "aws_api_gateway_deployment" "deploy" {
  rest_api_id = aws_api_gateway_rest_api.api.id

  depends_on = [
    aws_api_gateway_integration.auth_request_lambda,
    aws_api_gateway_integration.auth_verify_lambda,
    aws_api_gateway_integration.vote_lambda,
    aws_api_gateway_integration.admin_results_lambda,
    aws_api_gateway_integration.admin_export_lambda
  ]
}
resource "aws_api_gateway_stage" "prod" {
  stage_name    = "prod"
  rest_api_id   = aws_api_gateway_rest_api.api.id
  deployment_id = aws_api_gateway_deployment.deploy.id
}
