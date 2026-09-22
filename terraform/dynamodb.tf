data "aws_caller_identity" "current" {}

resource "aws_dynamodb_table" "employees" {
  name         = "Employees"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "EmployeeID"

  attribute {
    name = "EmployeeID"
    type = "S"
  }

  deletion_protection_enabled = false
}

locals {
  student_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${var.student_iam_user}"
}

resource "aws_dynamodb_table_item" "student" {
  table_name = aws_dynamodb_table.employees.name
  hash_key   = aws_dynamodb_table.employees.hash_key

  item = jsonencode({
    EmployeeID  = { S = var.student_employee_id }
    Name        = { S = var.student_name }
    Salary      = { N = "95000" }
    DateOfJoin  = { S = "2026-01-15" }
    Description = { S = local.student_arn }
  })
}
