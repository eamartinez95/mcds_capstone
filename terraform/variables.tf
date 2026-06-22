variable "aws_region"       { default = "us-east-1" }
variable "project_name"     { default = "ocr-app" }
variable "db_username"      { default = "admin" }
variable "db_password"      { sensitive = true }
variable "ecs_image_uri"    { description = "URI de la imagen Docker en ECR" }