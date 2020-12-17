resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "fleet-scanners-lambda-buckets"
  acl    = "public-read"

  tags = {
    Name        = "Lambda Buckets"
    Environment = "Production"
  }
}

data "archive_file" "lambda_source" {
  type        = "zip"
  source_dir  = "../build/"
  output_path = "./scan-service.zip"
}

resource "aws_s3_bucket_object" "lambda_upload" {
  bucket = aws_s3_bucket.lambda_bucket.id
  key    = "scan-service.zip"
  source = data.archive_file.lambda_source.output_path
  etag = filemd5(data.archive_file.lambda_source.output_path)
}

output "s3_bucket" {
  value = aws_s3_bucket.lambda_bucket.bucket
}
