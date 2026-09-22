data "aws_iam_policy_document" "lambda_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# Role names and paths are the ones created by the Lambda console.
resource "aws_iam_role" "ui" {
  name               = "Assignment-2-UI-role-uf09f1d9"
  path               = "/service-role/"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
}

resource "aws_iam_role" "backend" {
  name               = "Assignment-2-UI-role-j37ozh67"
  path               = "/service-role/"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
}

data "aws_iam_policy_document" "ui_logs" {
  statement {
    effect    = "Allow"
    actions   = ["logs:CreateLogGroup"]
    resources = ["arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = [
      "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/Assignment-2-UI:*",
    ]
  }
}

resource "aws_iam_policy" "ui_logs" {
  name   = "AWSLambdaBasicExecutionRole-8f82d8fa-df1a-40ae-bc2d-1152e73ab084"
  path   = "/service-role/"
  policy = data.aws_iam_policy_document.ui_logs.json
}

resource "aws_iam_policy" "backend_logs" {
  name   = "AWSLambdaBasicExecutionRole-0a676027-703a-40c9-8592-92234e3f23c5"
  path   = "/service-role/"
  policy = data.aws_iam_policy_document.ui_logs.json
}

resource "aws_iam_role_policy_attachment" "ui_logs" {
  role       = aws_iam_role.ui.name
  policy_arn = aws_iam_policy.ui_logs.arn
}

resource "aws_iam_role_policy_attachment" "backend_logs" {
  role       = aws_iam_role.backend.name
  policy_arn = aws_iam_policy.backend_logs.arn
}

resource "aws_iam_role_policy_attachment" "backend_dynamodb_read" {
  role       = aws_iam_role.backend.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "backend_dynamodb_streams" {
  role       = aws_iam_role.backend.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaDynamoDBExecutionRole"
}

resource "aws_iam_role_policy_attachment" "backend_dynamodb_invoke" {
  role       = aws_iam_role.backend.name
  policy_arn = "arn:aws:iam::aws:policy/AWSLambdaInvocation-DynamoDB"
}
