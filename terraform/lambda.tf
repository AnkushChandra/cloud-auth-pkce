resource "aws_cloudwatch_log_group" "ui" {
  name = "/aws/lambda/Assignment-2-UI"
}

resource "aws_cloudwatch_log_group" "backend" {
  name = "/aws/lambda/Assignment-2-backend"
}

data "archive_file" "ui" {
  type        = "zip"
  source_file = "${path.module}/../lambda/ui/index.mjs"
  output_path = "${path.module}/build/ui.zip"
}

data "archive_file" "backend" {
  type        = "zip"
  source_file = "${path.module}/../lambda/backend/lambda_function.py"
  output_path = "${path.module}/build/backend.zip"
}

resource "aws_lambda_function" "ui" {
  function_name    = "Assignment-2-UI"
  role             = aws_iam_role.ui.arn
  runtime          = "nodejs22.x"
  handler          = "index.handler"
  filename         = data.archive_file.ui.output_path
  source_code_hash = data.archive_file.ui.output_base64sha256
  timeout          = 3
  memory_size      = 128

  environment {
    variables = {
      COGNITO_DOMAIN    = "https://${aws_cognito_user_pool_domain.this.domain}.auth.${var.aws_region}.amazoncognito.com"
      COGNITO_CLIENT_ID = aws_cognito_user_pool_client.this.id
    }
  }

  depends_on = [aws_iam_role_policy_attachment.ui_logs]

  # The deployed package is already in AWS. Tracking the local zip would upload
  # a newly compressed copy of the same source on the next apply.
  lifecycle {
    ignore_changes = [filename, source_code_hash]
  }
}

resource "aws_lambda_function" "backend" {
  function_name    = "Assignment-2-backend"
  role             = aws_iam_role.backend.arn
  runtime          = "python3.12"
  handler          = "lambda_function.lambda_handler"
  filename         = data.archive_file.backend.output_path
  source_code_hash = data.archive_file.backend.output_base64sha256
  timeout          = 3
  memory_size      = 128

  environment {
    variables = {
      EMPLOYEE_TABLE = aws_dynamodb_table.employees.name
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.backend_logs,
    aws_iam_role_policy_attachment.backend_dynamodb_read,
  ]

  lifecycle {
    ignore_changes = [filename, source_code_hash]
  }
}
