resource "aws_dynamodb_table_item" "voters" {
  for_each = toset([
    "user1@gmail.com",
    "user2@gmail.com",
    "user3@gmail.com"
  ])

  table_name = aws_dynamodb_table.voters.name
  hash_key   = "email"

  item = jsonencode({
    email = each.value
  })
}
