resource "aws_dynamodb_table" "voters" {
  name         = "voter-registry"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "mobile"

  attribute {
    name = "mobile"
    type = "S"
  }
}

resource "aws_dynamodb_table" "otp" {
  name         = "otp-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "mobile"

  attribute {
    name = "mobile"
    type = "S"
  }

  ttl {
    attribute_name = "expiry"
    enabled        = true
  }
}

resource "aws_dynamodb_table" "votes" {
  name         = "votes"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "post_id"
  range_key    = "voter_id"

  attribute {
    name = "post_id"
    type = "S"
  }

  attribute {
    name = "voter_id"
    type = "S"
  }
}
