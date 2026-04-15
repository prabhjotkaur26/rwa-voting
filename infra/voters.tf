resource "aws_dynamodb_table_item" "voters" {
  for_each = toset(var.voter_emails)

  table_name = aws_dynamodb_table.voters.name
  hash_key   = "email"

  item = jsonencode({
    email = {
      S = each.value
    }
  })
}
