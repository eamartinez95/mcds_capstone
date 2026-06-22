resource "aws_lambda_function" "postprocesamiento" {
  function_name = "${var.project_name}-fnc-inscripcion-response"
  filename      = "${path.module}/lambdas/postprocesamiento.zip"
  handler       = "index.handler"
  runtime       = "python3.12"
  role          = aws_iam_role.lambda_role.arn
  timeout       = 60
  memory_size   = 512
}