resource "aws_lambda_permission" "lambda_permission" {
  function_name = "VisitorCounterLambda"
  principal     = "apigateway.amazonaws.com"
  action        = "lambda:InvokeFunction"
  source_arn    = "${aws_apigatewayv2_api.VisitorCounterAPI.execution_arn}/*/*/VisitorCounterLambda"
}

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
  name               = "VisitorCounterLambda-role-lzti59f6"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  tags               = {}
  path               = "/service-role/"

}


resource "aws_iam_role_policy_attachment" "AmazonDynamoDBFullAccess" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}


resource "aws_iam_role_policy_attachment" "AWSLambdaBasicExecutionRole" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/service-role/AWSLambdaBasicExecutionRole-6ccc721e-bb28-429e-9f3a-58eaffde1f1c"
}
