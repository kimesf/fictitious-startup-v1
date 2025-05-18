resource "aws_budgets_budget" "budget_entire_project" {
  name              = "budget-entire-project-monthly"
  budget_type       = "COST"
  limit_amount      = "0"
  limit_unit        = "USD"
  time_unit         = "MONTHLY"

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = ["kim.emmanuel@codeminer42.com"]
  }
}
