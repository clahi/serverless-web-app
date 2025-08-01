data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    actions = [ "sts:AssumeRole" ]
  }
}

resource "aws_iam_role" "lambda_auth_role" {
  name = "lambda_execution_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role = aws_iam_role.lambda_auth_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "archive_file" "function_file" {
  type = "zip"
  source_file = "${path.module}/function/auth.py"
  output_path = "${path.module}/function/auth.zip"
}

resource "aws_lambda_function" "testauth" {
  filename = data.archive_file.function_file.output_path
  function_name = "testauth"
  role = aws_iam_role.lambda_auth_role.arn
  handler = "auth.lambda_handler"
  source_code_hash = data.archive_file.function_file.output_base64sha256
  runtime = "python3.9"

  tags = {
    environemnt = var.environemnt
  }
}

# resource "aws_lambda_permission" "lambda_permission_auth" {
#   statement_id = "AllowExecutionFromHttpApi"
#   action = "lambda:InvokeFunction"
#   function_name = aws_lambda_function.testauth.function_name
#   principal = "apigateway.amazonaws.com"
#   source_arn = "${var.api_execution_arn}/*/*"
# }