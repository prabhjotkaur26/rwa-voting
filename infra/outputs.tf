########################################
# API GATEWAY URL
########################################
output "api_gateway_url" {
  description = "Base URL of HTTP API Gateway"
  value       = aws_apigatewayv2_api.api.api_endpoint
}

########################################
# FRONTEND WEBSITE URL
########################################
output "frontend_url" {
  description = "S3 hosted frontend URL"
  value       = aws_s3_bucket_website_configuration.frontend.website_endpoint
}

########################################
# FRONTEND BUCKET NAME
########################################
output "frontend_bucket_name" {
  description = "Frontend S3 bucket name"
  value       = aws_s3_bucket.frontend.id
}

########################################
# CSV UPLOAD BUCKET NAME
########################################
output "csv_bucket_name" {
  description = "CSV upload bucket name"
  value       = aws_s3_bucket.csv_bucket1.id
}
