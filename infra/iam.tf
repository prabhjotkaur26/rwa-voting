# -------------------------------
# IAM ROLE FOR LAMBDA
# -------------------------------
resource "aws_iam_role" "lambda_role" {
  name = "lambda-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

# -------------------------------
# BASIC LAMBDA LOGS POLICY
# -------------------------------
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# -------------------------------
# CUSTOM POLICY (SECURE VERSION)
# -------------------------------
resource "aws_iam_role_policy" "lambda_custom_policy" {
  name = "lambda-custom-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [

      # -----------------------
      # DYNAMODB ACCESS (LIMITED)
      # -----------------------
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query"
        ]
        Resource = [
          aws_dynamodb_table.voters rwa-voters.arn,
          aws_dynamodb_table.otp rwa-otp.arn,
          aws_dynamodb_table.votes rwa-votes.arn,
          aws_dynamodb_table.election rwa-election.arn
        ]
      },

      # -----------------------
      # S3 ACCESS (SAFE)
      # -----------------------
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = "*"
      },

      # -----------------------
      # SES EMAIL OTP
      # -----------------------
      {
        Effect = "Allow"
        Action = [
          "ses:SendEmail",
          "ses:SendRawEmail"
        ]
        Resource = "*"
      },

      # -----------------------
      # CLOUDWATCH LOGS (EXTRA SAFE)
      # -----------------------
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }

    ]
  })
}
