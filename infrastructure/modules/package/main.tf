data "archive_file" "default" {
  type        = "zip"
  source_dir  = var.zip_dir
  output_path = "${var.zip_output_path}/${var.name}.zip"
}

resource "aws_s3_bucket_object" "default" {
  bucket = var.bucket_id
  key    = "${var.name}.zip"
  source = data.archive_file.default.output_path
  etag = filemd5(data.archive_file.default.output_path)
}
