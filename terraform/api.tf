resource "aws_apigatewayv2_api" "VisitorCounterAPI" {
  name          = "VisitorCounterAPI"
  protocol_type = "HTTP"
  cors_configuration {
    allow_credentials = false
    allow_headers     = []
    allow_methods = [
      "GET",
      "POST",
    ]
    allow_origins = [
      "https://${var.website-bucket}",
    ]
    expose_headers = []
    max_age        = 0
  }
}

data "aws_apigatewayv2_api" "VisitorCounterAPI_id" {
  api_id = aws_apigatewayv2_api.VisitorCounterAPI.id
}

resource "aws_apigatewayv2_route" "VisitorCounterRouteGET" {
  route_key            = "GET /VisitorCounterLambda"
  api_id               = data.aws_apigatewayv2_api.VisitorCounterAPI_id.api_id
  authorization_scopes = []
  request_models       = {}
  target               = "integrations/${aws_apigatewayv2_integration.VisitorCounterIntegrationGET.id}"
}

resource "aws_apigatewayv2_route" "VisitorCounterRoutePOST" {
  route_key            = "POST /VisitorCounterLambda"
  api_id               = data.aws_apigatewayv2_api.VisitorCounterAPI_id.api_id
  authorization_scopes = []
  request_models       = {}
  target               = "integrations/${aws_apigatewayv2_integration.VisitorCounterIntegrationPOST.id}"
}

resource "aws_apigatewayv2_integration" "VisitorCounterIntegrationGET" {
  integration_type       = "AWS_PROXY"
  api_id                 = data.aws_apigatewayv2_api.VisitorCounterAPI_id.api_id
  integration_method     = "POST"
  integration_uri        = "arn:aws:lambda:${var.AWS_REGION}:${data.aws_caller_identity.current.account_id}:function:VisitorCounterLambda"
  payload_format_version = "2.0"
  request_parameters     = {}
  request_templates      = {}
  timeout_milliseconds   = 30000
}

data "aws_caller_identity" "current" {}

resource "aws_apigatewayv2_integration" "VisitorCounterIntegrationPOST" {
  integration_type       = "AWS_PROXY"
  api_id                 = data.aws_apigatewayv2_api.VisitorCounterAPI_id.api_id
  integration_method     = "POST"
  integration_uri        = "arn:aws:lambda:${var.AWS_REGION}:${data.aws_caller_identity.current.account_id}:function:VisitorCounterLambda"
  payload_format_version = "2.0"
  request_parameters     = {}
  request_templates      = {}
  timeout_milliseconds   = 30000
}

resource "aws_apigatewayv2_stage" "VisitorCounterStage" {
  name        = "$default"
  api_id      = data.aws_apigatewayv2_api.VisitorCounterAPI_id.api_id
  auto_deploy = true
}