## Archive Trivia Lambda
data "archive_file" "VisitorCounterLambda" {
  type        = "zip"
  source_file = "${path.module}/../src/VisitorCounterLambda.py"
  output_path = "${path.module}/zips/visitorLambda_payload.zip"
}

resource "aws_lambda_function" "VisitorCounterLambda" {
  architectures                  = ["x86_64"]
  code_signing_config_arn        = null
  description                    = null
  filename                       = "${path.module}/zips/visitorLambda_payload.zip"
  function_name                  = "arn:aws:lambda:${var.AWS_REGION}:${data.aws_caller_identity.current.account_id}:function:VisitorCounterLambda"
  handler                        = "VisitorCounterLambda.lambda_handler"
  memory_size                    = 128
  package_type                   = "Zip"
  reserved_concurrent_executions = -1
  role                           = aws_iam_role.iam_for_lambda.arn
  runtime                        = "python3.13"
  skip_destroy                   = false
  timeout                        = 3
}