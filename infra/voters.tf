resource "aws_dynamodb_table" "voter_registry" {
  name         = "voter_registry"
  billing_mode = "PAY_PER_REQUEST"

  hash_key = "email"

  attribute {
    name = "email"
    type = "S"
  }

  # Optional attributes (not required for key schema, but useful logically)
  attribute {
    name = "is_active"
    type = "N"
  }

  # Enable encryption
  server_side_encryption {
    enabled = true
  }

  # Enable point-in-time recovery (optional but recommended)
  point_in_time_recovery {
    enabled = true
  }

  tags = {
    Project = "RWA-Voting-System"
    Env     = "prod"
  }
}