## Archive Trivia Lambda
data "archive_file" "VisitorCounterLambda" {
  type        = "zip"
  source_file = "${path.module}/../src/VisitorCounterLambda.py"
  output_path = "${path.module}/zips/visitorLambda_payload.zip"
}


resource "aws_lambda_function" "VisitorCounterLambda" {
  architectures                      = ["x86_64"]
  code_signing_config_arn            = null
  description                        = null
  filename                           = "${path.module}/zips/visitorLambda_payload.zip"
  function_name                      = "arn:aws:lambda:eu-west-2:650251716475:function:VisitorCounterLambda"
  handler                            = "VisitorCounterLambda.lambda_handler"
  memory_size                        = 128
  package_type                       = "Zip"
  reserved_concurrent_executions     = -1
  role                               = "arn:aws:iam::650251716475:role/service-role/VisitorCounterLambda-role-lzti59f6"
  runtime                            = "python3.13"
 
  skip_destroy                       = false
  timeout                            = 3
}


resource "aws_lambda_permission" "lambda_permission" {
    function_name = "VisitorCounterLambda"
    principal = "apigateway.amazonaws.com"
    action        = "lambda:InvokeFunction"
    source_arn = "arn:aws:execute-api:eu-west-2:650251716475:whnuzf2r2k/*/*/VisitorCounterLambda"
}

##### Lambda DynamoDB role

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}


resource "aws_iam_role" "iam_for_lambda" {
  name               = var.VC_Lambda_IAM_Role_name
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
    tags = {}
    path = "/service-role/"

}


resource "aws_iam_role_policy_attachment" "AmazonDynamoDBFullAccess" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}


resource "aws_iam_role_policy_attachment" "AWSLambdaBasicExecutionRole" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = "arn:aws:iam::650251716475:policy/service-role/AWSLambdaBasicExecutionRole-6ccc721e-bb28-429e-9f3a-58eaffde1f1c"
}

#####

resource "aws_apigatewayv2_api" "VisitorCounterAPI" {
  name          = "VisitorCounterAPI"
  protocol_type = "HTTP"
  cors_configuration {
          allow_credentials = false
          allow_headers     = []
          allow_methods     = [
              "GET",
              "POST",
            ]
          allow_origins     = [
              "https://${var.website-bucket}",
            ]
          expose_headers    = []
          max_age           = 0
        }
}

data "aws_apigatewayv2_api" "VisitorCounterAPI_id" {
    api_id = aws_apigatewayv2_api.VisitorCounterAPI.id
}

resource "aws_apigatewayv2_route" "VisitorCounterRouteGET" {
    route_key = "GET /VisitorCounterLambda"
    api_id = data.aws_apigatewayv2_api.VisitorCounterAPI_id.api_id
    authorization_scopes = []
    request_models = {}
    target = "integrations/${var.VC_API_Integration_GET_ID}"
}

resource "aws_apigatewayv2_route" "VisitorCounterRoutePOST" {
  route_key = "POST /VisitorCounterLambda"
  api_id = data.aws_apigatewayv2_api.VisitorCounterAPI_id.api_id
  authorization_scopes = []
  request_models = {}
  target = "integrations/${var.VC_API_Integration_POST_ID}"
}

resource "aws_apigatewayv2_integration" "VisitorCounterIntegrationGET" {
  integration_type = "AWS_PROXY"
  api_id = data.aws_apigatewayv2_api.VisitorCounterAPI_id.api_id
  integration_method = "POST"
  integration_uri = "arn:aws:lambda:${var.AWS_REGION}:${data.aws_caller_identity.current.account_id}:function:VisitorCounterLambda"
  payload_format_version = "2.0"
  request_parameters = {}
  request_templates = {}
  timeout_milliseconds = 30000
}

data "aws_caller_identity" "current" {}

resource "aws_apigatewayv2_integration" "VisitorCounterIntegrationPOST" {
  integration_type = "AWS_PROXY"
  api_id = data.aws_apigatewayv2_api.VisitorCounterAPI_id.api_id
  integration_method = "POST"
  integration_uri = "arn:aws:lambda:${var.AWS_REGION}:${data.aws_caller_identity.current.account_id}:function:VisitorCounterLambda"
  payload_format_version = "2.0"
  request_parameters = {}
  request_templates = {}
  timeout_milliseconds = 30000
}

resource "aws_apigatewayv2_stage" "VisitorCounterStage" {
  name = "$default"
  api_id = data.aws_apigatewayv2_api.VisitorCounterAPI_id.api_id
  auto_deploy = true
}

resource "aws_dynamodb_table" "VisitorCounter" {
    name = "VisitorCounter"
    billing_mode = "PAY_PER_REQUEST"
    attribute {
            name = "id"
            type = "S"
        }
}
