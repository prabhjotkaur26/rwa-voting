
############################################
# VOTERS TABLE
############################################
resource "aws_dynamodb_table" "voters" {
  name         = "voter-registry"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "email"

  attribute {
    name = "email"
    type = "S"
  }

  tags = {
    Name        = "voter-registry"
    Environment = "prod"
  }
}

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

  hash_key  = "post_id"
  range_key = "voter_id"

  attribute {
    name = "post_id"
    type = "S"
  }

  attribute {
    name = "voter_id"
    type = "S"
  }

  global_secondary_index {
    name            = "voter-index"
    hash_key        = "voter_id"
    projection_type = "ALL"
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
