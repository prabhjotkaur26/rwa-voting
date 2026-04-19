############################################
# VOTERS TABLE
############################################
resource "aws_dynamodb_table" "voters" {
  name         = "voter-registry"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "email"
    type = "S"
  }

  key_schema {
    attribute_name = "email"
    key_type       = "HASH"
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

  attribute {
    name = "email"
    type = "S"
  }

  key_schema {
    attribute_name = "email"
    key_type       = "HASH"
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

  ##################################
  # ATTRIBUTES
  ##################################
  attribute {
    name = "post_id"
    type = "S"
  }

  attribute {
    name = "voter_id"
    type = "S"
  }

  ##################################
  # PRIMARY KEY
  ##################################
  key_schema {
    attribute_name = "post_id"
    key_type       = "HASH"
  }

  key_schema {
    attribute_name = "voter_id"
    key_type       = "RANGE"
  }

  ##################################
  # GSI (NEW SYNTAX)
  ##################################
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

  attribute {
    name = "post_id"
    type = "S"
  }

  key_schema {
    attribute_name = "post_id"
    key_type       = "HASH"
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

  attribute {
    name = "id"
    type = "S"
  }

  key_schema {
    attribute_name = "id"
    key_type       = "HASH"
  }

  tags = {
    Name        = "audit-logs"
    Environment = "prod"
  }
}
