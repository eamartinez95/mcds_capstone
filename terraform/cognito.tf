# ─── USER POOL ───────────────────────────────────────────
resource "aws_cognito_user_pool" "main" {
  name = "${var.project_name}-user-pool"
}

# ─── DOMAIN (requerido para /oauth2/token) ───────────────
resource "aws_cognito_user_pool_domain" "main" {
  domain       = "${var.project_name}-auth"
  user_pool_id = aws_cognito_user_pool.main.id
}

# ─── RESOURCE SERVER ─────────────────────────────────────
resource "aws_cognito_resource_server" "main" {
  identifier   = "https://${var.project_name}.api"
  name         = "${var.project_name}-resource-server"
  user_pool_id = aws_cognito_user_pool.main.id

  scope {
    scope_name        = "access"
    scope_description = "Acceso general a la API"
  }
}

# ─── APP CLIENT M2M ──────────────────────────────────────
resource "aws_cognito_user_pool_client" "m2m" {
  name         = "${var.project_name}-m2m-client"
  user_pool_id = aws_cognito_user_pool.main.id

  generate_secret                      = true
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["client_credentials"]

  allowed_oauth_scopes = [
    "${aws_cognito_resource_server.main.identifier}/access"
  ]

  explicit_auth_flows = []

  depends_on = [aws_cognito_resource_server.main]
}