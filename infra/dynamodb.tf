############################################
# OTP TABLE
############################################
resource "aws_dynamodb_table" "otp" {
  name         = "otp-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "email"

  attribute {
    name = "email"
    type = "S"
  }

  ttl {
    attribute_name = "expiry"
    enabled        = true
  }

  tags = {
    Name        = "otp-table"
    Environment = "prod"
  }
}

############################################
# VOTES TABLE
############################################
resource "aws_dynamodb_table" "votes" {
  name         = "votes"
  billing_mode = "PAY_PER_REQUEST"

  hash_key  = "PK"
  range_key = "SK"

  attribute {
    name = "PK"
    type = "S"
  }

  attribute {
    name = "SK"
    type = "S"
  }

  tags = {
    Name        = "votes"
    Environment = "prod"
  }
}

############################################
# ELECTION CONFIG TABLE
############################################
resource "aws_dynamodb_table" "election" {
  name         = "election-config"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "post_id"

  attribute {
    name = "post_id"
    type = "S"
  }

  tags = {
    Name        = "election-config"
    Environment = "prod"
  }
}

############################################
# AUDIT TABLE
############################################
resource "aws_dynamodb_table" "audit" {
  name         = "audit-logs"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }
}
