resource "aws_s3_bucket" "website-bucket" {
  bucket = "www.${var.website-bucket}"
}
data "aws_s3_bucket" "selected-bucket" {
  bucket = aws_s3_bucket.website-bucket.bucket
}