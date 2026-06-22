resource "aws_sfn_state_machine" "ocr_workflow" {
  name     = "${var.project_name}-ocr-workflow"
  role_arn = aws_iam_role.sfn_role.arn
  type     = "EXPRESS"

  definition = jsonencode({
    Comment = "Procesamiento de documentos"
    StartAt = "ProcesarDocumentos"
    States = {
      ProcesarDocumentos = {
        Type           = "Map"
        ItemsPath      = "$.documents"
        MaxConcurrency = 5
        ResultPath     = "$.processedResults"
        Iterator = {
          StartAt = "ProcesarDocumento"
          States = {
            ProcesarDocumento = {
              Type     = "Task"
              Resource = aws_lambda_function.ocr.arn
              End      = true
            }
          }
        }
        Next = "LambdaFinal"
      }
      LambdaFinal = {
        Type     = "Task"
        Resource = aws_lambda_function.postprocesamiento.arn
        End      = true
      }
    }
  })
}