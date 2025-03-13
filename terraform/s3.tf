resource "aws_s3_bucket" "test-bucket" {
  bucket_prefix = "andrewstride-"
}

# Website bucket
resource "aws_s3_bucket" "website-bucket" {
  bucket = var.website-bucket
}
data "aws_s3_bucket" "selected-bucket" {
  bucket = aws_s3_bucket.website-bucket.bucket
}

resource "aws_s3_bucket" "log-bucket" {
  bucket = var.log-bucket
}

resource "aws_s3_bucket_logging" "log" {
  bucket = data.aws_s3_bucket.selected-bucket.bucket

  target_bucket = var.log-bucket
  target_prefix = "logs/"
}

# Enable Versioning
resource "aws_s3_bucket_versioning" "enable-versioning" {
  bucket = data.aws_s3_bucket.selected-bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "allow-public-access" {
  bucket                  = data.aws_s3_bucket.selected-bucket.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Bucket Policy for Public Read Access
resource "aws_s3_bucket_policy" "bucket-policy" {
  bucket     = data.aws_s3_bucket.selected-bucket.id
  policy     = data.aws_iam_policy_document.iam-policy-public-read.json
  depends_on = [aws_s3_bucket_public_access_block.allow-public-access]
}

# IAM Policy Document for Public Read Access
data "aws_iam_policy_document" "iam-policy-public-read" {
  statement {
    sid    = "AllowPublicRead"
    effect = "Allow"
    resources = [
      "arn:aws:s3:::${data.aws_s3_bucket.selected-bucket.bucket}",
      "arn:aws:s3:::${data.aws_s3_bucket.selected-bucket.bucket}/*"
    ]
    actions = ["S3:GetObject"]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}

resource "aws_s3_bucket_website_configuration" "website-config" {
  bucket = data.aws_s3_bucket.selected-bucket.bucket
  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "index.html"
  }
}


# Upload HTML files
resource "aws_s3_object" "object-upload-html" {
  for_each = fileset("../uploads/", "*.html")

  bucket       = data.aws_s3_bucket.selected-bucket.bucket
  key          = each.value
  source       = "../uploads/${each.value}"
  content_type = "text/html"
  etag         = filemd5("../uploads/${each.value}")
}

# Upload PNG files
resource "aws_s3_object" "object-upload-png" {
  for_each = fileset("../uploads/assets/images/", "*.png")

  bucket       = data.aws_s3_bucket.selected-bucket.bucket
  key          = "assets/images/${each.value}"
  source       = "../uploads/assets/images/${each.value}"
  content_type = "image/png"
  etag         = filemd5("../uploads/assets/images/${each.value}")
}

# Upload GIF files
resource "aws_s3_object" "object-upload-gif" {
  for_each = fileset("../uploads/assets/images/", "*.gif")

  bucket       = data.aws_s3_bucket.selected-bucket.bucket
  key          = "assets/images/${each.value}"
  source       = "../uploads/assets/images/${each.value}"
  content_type = "image/gif"
  etag         = filemd5("../uploads/assets/images/${each.value}")
}

# Upload CSS files (styles)
resource "aws_s3_object" "object-upload-css" {
  for_each = fileset("../uploads/assets/css/", "*.css")

  bucket       = data.aws_s3_bucket.selected-bucket.bucket
  key          = "assets/css/${each.value}"
  source       = "../uploads/assets/css/${each.value}"
  content_type = "text/css"
  etag         = filemd5("../uploads/assets/css/${each.value}")
}

# Upload JS files
resource "aws_s3_object" "object-upload-js" {
  for_each = fileset("../uploads/", "app.js")

  bucket       = data.aws_s3_bucket.selected-bucket.bucket
  key          = each.value
  source       = "../uploads/${each.value}"
  content_type = "application/javascript"
  etag         = filemd5("../uploads/${each.value}")
}
