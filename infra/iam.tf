########################################
# IAM ROLE FOR LAMBDA
########################################
resource "aws_iam_role" "lambda_role" {
  name = "lambda-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

########################################
# BASIC LAMBDA LOGGING POLICY
########################################
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

########################################
# CUSTOM POLICY (DYNAMODB + S3 + SES)
########################################
resource "aws_iam_role_policy" "lambda_custom_policy" {
  name = "lambda-custom-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [

      ########################################
      # DYNAMODB ACCESS
      ########################################
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:BatchWriteItem"
        ]
        Resource = [
          aws_dynamodb_table.voter_registry.arn,
          aws_dynamodb_table.otp.arn,
          aws_dynamodb_table.votes.arn,
          aws_dynamodb_table.election.arn,
          "${aws_dynamodb_table.voter_registry.arn}/index/*",
          "${aws_dynamodb_table.votes.arn}/index/*"
        ]
      },

      ########################################
      # S3 ACCESS (FIXED)
      ########################################
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
         "arn:aws:s3:::voter-csv-upload-bucket-12345",
         "arn:aws:s3:::voter-csv-upload-bucket-12345/*"
        ]
      },

      ########################################
      # SES EMAIL OTP
      ########################################
      {
        Effect = "Allow"
        Action = [
          "ses:SendEmail",
          "ses:SendRawEmail"
        ]
        Resource = "*"
      }

    ]
  })

  # ✅ ensure proper creation order
  depends_on = [
    aws_dynamodb_table.voter_registry,
    aws_dynamodb_table.otp,
    aws_dynamodb_table.votes,
    aws_dynamodb_table.election,
    aws_s3_bucket.csv_bucket1
  ]
}
