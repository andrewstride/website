# import {
#   to = aws_lambda_function.triviaLambda
#   id = "arn:aws:lambda:eu-west-2:650251716475:function:triviaLambda"
# }

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
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${path.module}/test_lambda/testLambda.py"
  output_path = "${path.module}/zips/testLambda_payload.zip"
}

resource "aws_lambda_function" "test_lambda" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = "${path.module}/zips/testLambda_payload.zip"
  function_name = "testLambda"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "testLambda.lambda_handler"

  source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = "python3.13"
}
