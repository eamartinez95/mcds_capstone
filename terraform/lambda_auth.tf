data "archive_file" "lambda_auth_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambdas/auth"
  output_path = "${path.module}/lambdas/auth.zip"
}

resource "aws_lambda_function" "auth" {
  function_name    = "${var.project_name}-auth"
  filename         = data.archive_file.lambda_auth_zip.output_path
  source_code_hash = data.archive_file.lambda_auth_zip.output_base64sha256
  handler          = "index.handler"
  runtime          = "python3.12"
  role             = aws_iam_role.lambda_role.arn

  environment {
    variables = {
      COGNITO_CLIENT_ID = aws_cognito_user_pool_client.main.id
      USER_POOL_ID      = aws_cognito_user_pool.main.id
    }
  }
}