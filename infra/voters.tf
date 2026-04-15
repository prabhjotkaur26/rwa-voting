resource "aws_dynamodb_table_item" "voters" {
  for_each = toset([
    "prabh008968@gmail.com",
    "kaurprabhsidhu852004@gmail.com",
    "prabhjot582004@gmail.com"
  ])

  table_name = aws_dynamodb_table.voters.name
  hash_key   = "email"

  item = jsonencode({
    email = each.value
  })
}
