terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.54.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.2"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "random_id" "ran_id" {
  byte_length = 8
}

resource "aws_s3_bucket" "webapp-bucket" {
  bucket = "webapp-bucket-${random_id.ran_id.hex}"
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.webapp-bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "webapp" {
  bucket = aws_s3_bucket.webapp-bucket.id
  policy = jsonencode(
    {
      Version = "2012-10-17",
      Statement = [
        {
          Sid       = "PublicReadGetObject",
          Effect    = "Allow",
          Principal = "*",
          Action    = "s3:GetObject",
          Resource  = "${aws_s3_bucket.webapp-bucket.arn}/*"
        }
      ]
    }
  )
}

resource "aws_s3_bucket_website_configuration" "webapp" {
  bucket = aws_s3_bucket.webapp-bucket.id

  index_document {
    suffix = "index.html"
  }
}


resource "aws_s3_object" "index_html" {
  bucket       = aws_s3_bucket.webapp-bucket.bucket
  source       = "./index.html"
  key          = "index.html"
  content_type = "text/html"
}

resource "aws_s3_object" "styles_css" {
  bucket       = aws_s3_bucket.webapp-bucket.bucket
  source       = "./styles.css"
  key          = "styles.css"
  content_type = "text/css"
}

output "name" {
  value = aws_s3_bucket_website_configuration.webapp.website_endpoint
}
