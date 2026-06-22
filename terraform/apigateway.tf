resource "aws_apigatewayv2_api" "main" {
  name          = "${var.project_name}-api"
  protocol_type = "HTTP"
}

# ─── STAGE ───────────────────────────────────────────────
resource "aws_apigatewayv2_stage" "main" {
  api_id      = aws_apigatewayv2_api.main.id
  name        = "$default"
  auto_deploy = true
}

# ─── AUTORIZADOR COGNITO ─────────────────────────────────
resource "aws_apigatewayv2_authorizer" "cognito" {
  api_id           = aws_apigatewayv2_api.main.id
  authorizer_type  = "JWT"
  name             = "${var.project_name}-cognito-authorizer"
  identity_sources = ["$request.header.Authorization"]

  jwt_configuration {
    audience = [aws_cognito_user_pool_client.main.id]
    issuer   = "https://cognito-idp.${var.aws_region}.amazonaws.com/${aws_cognito_user_pool.main.id}"
  }
}

# ─── INTEGRACIÓN: Lambda Auth ────────────────────────────
resource "aws_apigatewayv2_integration" "auth_lambda" {
  api_id                 = aws_apigatewayv2_api.main.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.auth.invoke_arn
  payload_format_version = "2.0"
}

# ─── INTEGRACIÓN: ECS (via ALB interno) ──────────────────
resource "aws_apigatewayv2_integration" "ecs_integration" {
  api_id                 = aws_apigatewayv2_api.main.id
  integration_type       = "HTTP_PROXY"
  integration_uri        = "http://${aws_lb.ecs_alb.dns_name}/{proxy}"
  integration_method     = "ANY"
  payload_format_version = "1.0"
}

# ─── RUTA: POST /auth — SIN autorizador ──────────────────
resource "aws_apigatewayv2_route" "auth_route" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "POST /auth"
  target    = "integrations/${aws_apigatewayv2_integration.auth_lambda.id}"

  # Sin authorization_type → pública
  authorization_type = "NONE"
}

# ─── RUTA: ANY /request/{proxy+} — CON autorizador Cognito ──
resource "aws_apigatewayv2_route" "request_route" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "ANY /request/{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.ecs_integration.id}"

  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito.id
}

# ─── PERMISO: API GW puede invocar Lambda Auth ───────────
resource "aws_lambda_permission" "auth_apigw" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.auth.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.main.execution_arn}/*/*"
}