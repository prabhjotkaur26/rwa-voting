# Import existing AWS resources into Terraform state
# Run this script from the infra/ directory

Write-Host "=== IMPORTING EXISTING AWS RESOURCES INTO TERRAFORM ===" -ForegroundColor Green

# Import IAM Role
Write-Host "Importing IAM Role..." -ForegroundColor Yellow
terraform import aws_iam_role.lambda_role lambda-execution-role

# Import DynamoDB Tables
Write-Host "Importing DynamoDB Tables..." -ForegroundColor Yellow
terraform import aws_dynamodb_table.otp otp-table
terraform import aws_dynamodb_table.votes votes
terraform import aws_dynamodb_table.election election

# Import S3 Buckets
Write-Host "Importing S3 Buckets..." -ForegroundColor Yellow
terraform import aws_s3_bucket.frontend rwa-frontend-bucket-1234
terraform import aws_s3_bucket.candidate_images rwa-voting-images
terraform import aws_s3_bucket.csv_bucket1 voter-csv-upload-bucket-12345

# Import Lambda Functions (with correct names)
Write-Host "Importing Lambda Functions..." -ForegroundColor Yellow
terraform import aws_lambda_function.csv_lambda csv-import-function
terraform import aws_lambda_function.auth csv_to_dynamodb
terraform import aws_lambda_function.vote rwa-voting-vote

Write-Host "=== IMPORT COMPLETE ===" -ForegroundColor Green
Write-Host "Now run: terraform plan" -ForegroundColor Cyan
Write-Host "Then run: terraform apply" -ForegroundColor Cyan