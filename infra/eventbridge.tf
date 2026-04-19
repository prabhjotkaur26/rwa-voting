resource "aws_cloudwatch_event_rule" "start_election" {
  name                = "start-election"
  schedule_expression = "cron(0 9 * * ? *)"
}

resource "aws_cloudwatch_event_rule" "end_election" {
  name                = "end-election"
  schedule_expression = "cron(0 18 * * ? *)"
}
