output "auth_api_url"    { value = aws_apigatewayv2_api.auth.api_endpoint }
output "request_api_url" { value = aws_apigatewayv2_api.request.api_endpoint }
output "s3_bucket"       { value = aws_s3_bucket.main.bucket }
output "rds_endpoint"    { value = aws_db_instance.main.address }
output "sfn_arn"         { value = aws_sfn_state_machine.ocr_workflow.arn }