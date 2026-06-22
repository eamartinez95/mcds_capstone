resource "aws_lambda_function" "ocr" {
  function_name = "${var.project_name}-fnc-inscripcion-process"
  filename      = "${path.module}/lambdas/ocr.zip"
  handler       = "index.handler"
  runtime       = "python3.12"
  role          = aws_iam_role.lambda_role.arn
  timeout       = 300
  memory_size   = 1024

  environment {
    variables = {
      S3_BUCKET = aws_s3_bucket.main.bucket
    }
  }
}