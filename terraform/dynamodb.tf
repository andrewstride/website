resource "aws_dynamodb_table" "VisitorCounter" {
  name         = "VisitorCounter"
  billing_mode = "PAY_PER_REQUEST"
  attribute {
    name = "id"
    type = "S"
  }
}
